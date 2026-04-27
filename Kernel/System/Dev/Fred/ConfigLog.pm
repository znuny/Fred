# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)

package Kernel::System::Dev::Fred::ConfigLog;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

use File::Spec;

our @ObjectDependencies = (
    'Kernel::Config',
);

=head1 NAME

Kernel::System::Dev::Fred::ConfigLog

=head1 DESCRIPTION

handle the config log data

=cut

=head2 Init()

    $BackendObject->Init();

=cut

sub Init {
    my ( $Self, %Param ) = @_;

    my %Config;

    $Config{LogFileName} = 'Config.log';
    $Config{LogFile}     = File::Spec->catfile( $Self->{LogDir}, 'Config.log' );

    # check if the needed path is available
    my $Path = $Self->{LogDir};
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

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my @LogMessages;
    my $Filehandle;
    if ( !open $Filehandle, '<', $Self->{LogFile} ) {    ## no critic
        print STDERR "Can't read $Self->{LogFile}\n";
        return;
    }
    LINE:
    for my $Line ( reverse <$Filehandle> ) {
        last LINE if $Line =~ /Fred-ConfigLog/;
        push @LogMessages, $Line;
    }
    close $Filehandle;
    pop @LogMessages;

    $Self->InsertWord( What => "Fred-ConfigLog\n" );

    my %IndividualConfig = ();

    for my $Line (@LogMessages) {
        $Line =~ s/\n//;
        $IndividualConfig{$Line}++;
    }

    @LogMessages = ();
    for my $Line ( sort keys %IndividualConfig ) {
        my @SplitedLine = split /;/, $Line;
        push @SplitedLine, $IndividualConfig{$Line};
        push @LogMessages, \@SplitedLine;
    }

    # sort the data
    my $Config = $ConfigObject->Get('Fred')->{'Module'}->{ConfigLog}->{Config};

    my $OrderBy = defined( $Config->{OrderBy} ) ? $Config->{OrderBy} : 3;
    if ( $OrderBy == 3 ) {
        @LogMessages = sort { $b->[$OrderBy] <=> $a->[$OrderBy] } @LogMessages;
    }
    else {
        @LogMessages = sort { $a->[$OrderBy] cmp $b->[$OrderBy] } @LogMessages;
    }

    $Param{ModuleRef}->{Data} = \@LogMessages;

    return 1;
}

=head2 InsertWord()

Save a word in the translation debug log

    $BackendObject->InsertWord(
        What => 'a word',
    );

=cut

sub InsertWord {
    my ( $Self, %Param ) = @_;

    return if !$Self->{Active};

    # save the word in log file
    open my $Filehandle, '>>', $Self->{LogFile} || die "Can't write $Self->{LogFile} !\n";
    print $Filehandle $Param{What} . "\n";
    close $Filehandle;

    return 1;
}

1;
