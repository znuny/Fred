# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::SQLLog;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

use Time::HiRes qw(gettimeofday tv_interval);

our @ObjectDependencies = (
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Dev::Fred::SQLLog

=head1 DESCRIPTION

handle the config log data

=cut

sub Init {
    my ( $Self, %Param ) = @_;

    my %Config;

    $Config{LogFileName} = 'SQL.log';
    $Config{LogFile}     = $Self->{Home} . $Self->{LogPath} . 'SQL.log';

    # check if the needed path is available
    my $Path = $Self->{Home} . $Self->{LogPath};
    if ( !-e $Path ) {
        File::Path::mkpath( $Path, 0, 0777 );    ## no critic
    }

    # check if needed LogFile exists
    if ( !-f $Config{LogFile} ) {
        open my $Filehandle, '>>', $Config{LogFile} || die "Can't write $Config{LogFile} !\n";
        print $Filehandle " ";
        close $Filehandle;
    }

    return \%Config;
}

=head2 DataGet()

Get the data for this Fred module. Returns true or false.
And add the data to the module ref.

    $BackendObject->DataGet(
        ModuleRef => $ModuleRef,
    );

=cut

sub DataGet {
    my ( $Self, %Param ) = @_;

    # open the file SQL.log
    my $Filehandle;
    if ( !open $Filehandle, '<', $Self->{LogFile} ) {    ## no critic
        $Param{ModuleRef}->{Data} = ["Can't read $Self->{LogFile}"];
        return;
    }

    my @LogMessages;
    my $DoStatements     = 0;
    my $SelectStatements = 0;

    # slurp in the whole logfile, in order to access the lines at the end
    LINE:
    for my $Line ( reverse <$Filehandle> ) {

        # do not show the log from the previous request
        last LINE if $Line =~ /Fred-SQLLog/;

     # a typical line from SQL.log looks like:
     # SQL-SELECT##!##SELECT 1 + 1 FROM dual WHERE id = ? AND user_id = ?##!##1, 2##!##Kernel::System::User##!##0.004397
        my @SplitLogLine = split /##!##/, $Line;
        if ( $SplitLogLine[0] eq 'SQL-DO' && $SplitLogLine[1] =~ m{ \A SELECT }xms ) {
            $SplitLogLine[0] .= ' - Perhaps you have an error you use DO for a SELECT-Statement:';
        }
        push @LogMessages, \@SplitLogLine;

        if ( $SplitLogLine[0] eq 'SQL-DO' ) {
            $DoStatements++;
        }

        if ( $SplitLogLine[4] ) {
            $Param{ModuleRef}->{Time} += $SplitLogLine[4];
        }
    }

    pop @LogMessages;
    close $Filehandle;

    # find SQL-statements used multiple times
    my %MultiUsed;
    for my $StatementRef (@LogMessages) {
        $MultiUsed{ $StatementRef->[1] }++;
    }
    for my $StatementRef (@LogMessages) {
        push @{$StatementRef}, ( $MultiUsed{ $StatementRef->[1] } - 1 );
    }

    # Add marker for the next view
    $Self->InsertWord( What => "Fred-SQLLog\n" );

    # set the data for the output template
    $Param{ModuleRef}->{Data}             = \@LogMessages;
    $Param{ModuleRef}->{AllStatements}    = scalar @LogMessages;
    $Param{ModuleRef}->{DoStatements}     = $DoStatements;
    $Param{ModuleRef}->{SelectStatements} = $Param{ModuleRef}->{AllStatements} - $DoStatements;

    return 1;
}

=head2 InsertWord()

Append a semicolon separated record line to the the SQL log.

    $BackendObject->InsertWord(
        What => 'SQL-SELECT;SELECT 1 + 1 FROM dual;Kernel::System::User;0.004397',
    );

=cut

sub InsertWord {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    return 1 if !$Self->{Active};

    if ( !$Param{What} ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need What!',
        );
        return;
    }

    # Fixup multiline SQL statements
    if ( $Param{What} =~ m/^SQL/smx ) {
        my @What = split '##!##', $Param{What};

        # hide white space
        $What[1] =~ s/\r?\n/ /smxg;
        $What[1] =~ s/\s+/ /smxg;
        $Param{What} = join '##!##', @What;
    }

    # append the line to log file
    open my $Filehandle, '>>', $Self->{LogFile} || die "Can't write $Self->{LogFile} !\n";
    print $Filehandle $Param{What}, "\n";
    close $Filehandle;

    return 1;
}

sub PreStatement {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    $Self->{PrepareStart} = [gettimeofday];

    return;
}

sub PostStatement {
    my ( $Self, %Param ) = @_;

    return if ( !$Self->{Active} );

    my $DiffTime = tv_interval( $Self->{PrepareStart} );

    my @StackTrace;

    COUNT:
    for ( my $Count = 1; $Count < 30; $Count++ ) {
        my ( $Package1, $Filename1, $Line1, $Subroutine1 ) = caller($Count);
        last COUNT if !$Line1;
        my ( $Package2, $Filename2, $Line2, $Subroutine2 ) = caller( 1 + $Count );
        $Subroutine2 ||= $0;    # if there is no caller module use the file name
        $Subroutine2 =~ s/Kernel::System/K::S/;
        $Subroutine2 =~ s/Kernel::Modules/K::M/;
        $Subroutine2 =~ s/Kernel::Output/K::O/;
        push @StackTrace, "$Subroutine2:$Line1";
    }

    my @Array = map { defined $_ && defined ${$_} ? ${$_} : 'undef' } @{ $Param{Bind} || [] };

    # Replace newlines
    @Array = map { $_ =~ s{\r?\n}{[\\n]}smxg; $_; } @Array;    ## no critic

    # Limit bind param length
    @Array = map { length($_) > 100 ? ( substr( $_, 0, 100 ) . '[...]' ) : $_ } @Array;
    my $BindString = @Array ? join ', ', @Array : '';

    my $Prefix = $Param{SQL} =~ m{^SELECT}ixms ? 'SELECT' : 'DO';

    $Self->InsertWord(
        What => "SQL-$Prefix##!##$Param{SQL}##!##$BindString##!##"
            . join( ';', @StackTrace )
            . "##!##$DiffTime",
    );

    return;
}

1;
