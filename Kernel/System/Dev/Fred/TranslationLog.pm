# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::TranslationLog;
use parent qw(Kernel::System::Dev::Fred::Base);

## no critic(Perl::Critic::Policy::OTRS::ProhibitOpen)

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Dev::Fred::TranslationLog

=head1 DESCRIPTION

handle the translation debug data

=cut

sub Init {
    my ( $Self, %Param ) = @_;

    my %Config;

    $Config{LogFileName} = 'Translation.log';
    $Config{LogFile}     = $Self->{LogFile};

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

    # open the TranslationLog.log file to get the untranslated words
    my $Filehandle;
    if ( !open $Filehandle, '<:encoding(UTF-8)', $Self->{LogFile} ) {    ## no critic
        $Param{ModuleRef}->{Data} = ["Can't read $Self->{LogFile}"];
        return;
    }

    # get distinct entries from TranslationLog.log
    # till the last 'Fred' entry
    my %LogLines;
    LINE:
    for my $Line ( reverse <$Filehandle> ) {
        last LINE if $Line =~ /Fred-TranslationLog/;

        chomp $Line;
        next LINE if $Line eq '';

        # skip duplicate entries
        next LINE if $LogLines{$Line};

        $LogLines{$Line} = 1;
    }
    close $Filehandle;

    $Self->InsertWord( What => "Fred-TranslationLog\n" );

    my @LogLines = sort { $a cmp $b } keys %LogLines;
    $Param{ModuleRef}->{Data} = \@LogLines;

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

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    return if !$Self->{Active};

    if ( !defined( $Param{What} ) ) {
        $LogObject->Log(
            Priority => 'error',
            Message  => 'Need What!',
        );
        return;
    }

    # save the word in log file
    open my $Filehandle, '>>:encoding(UTF-8)', $Self->{LogFile} || die "Can't write $Self->{LogFile} !\n";
    print $Filehandle $Param{What} . "\n";
    close $Filehandle;

    return 1;
}

1;
