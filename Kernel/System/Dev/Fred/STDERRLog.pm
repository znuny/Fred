# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)

package Kernel::System::Dev::Fred::STDERRLog;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

use IO::Handle;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Dev::Fred::STDERRLog

=head1 DESCRIPTION

handle the config log data

=cut

sub Init {
    my ( $Self, %Param ) = @_;

    my %Config;

    $Config{LogFileName} = 'STDERR.log';
    $Config{LogFile}     = $Self->{Home} . $Self->{LogPath} . 'STDERR.log';

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

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    NEEDED:
    for my $Needed (qw(ModuleRef)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!",
        );
        return;
    }

    # Make sure that we get everything to disk before trying to read it (otherwise content could be lost).
    STDERR->flush();

    # open the STDERR.log file to get the STDERR messages
    my $Filehandle;

    $Self->{LogFile} = $Self->{Home} . $Self->{LogPath} . 'STDERR.log';

    if ( !open $Filehandle, '<:encoding(UTF-8)', $Self->{LogFile} ) {    ## no critic
        $Param{ModuleRef}->{Data} = [
            "Perhaps you don't have permission at $Self->{LogPath} or /Kernel/Config/Files/AAAFred.pm.\n",
            "Can't read $Self->{LogFile}\n",
        ];
        return;
    }

    # Read log until last "Fred" marker.
    my @LogMessages;
    LINE:
    for my $Line ( reverse <$Filehandle> ) {
        last LINE if $Line =~ m{ \A \s* Fred-STDERR \s* \z}xms;
        push @LogMessages, $Line;
    }
    close $Filehandle;

    print STDERR "\nFred-STDERR\n";

    # trim the log message array
    LINE:
    for my $Line (@LogMessages) {
        last LINE if $Line !~ m{ \A \s* \z }xms;
        shift @LogMessages;
    }

    # trim the log message array
    LINE:
    for my $Line ( reverse @LogMessages ) {
        last LINE if $Line !~ m{ \A \s* \z }xms;
        shift @LogMessages;
    }

    $Param{ModuleRef}->{Data} = \@LogMessages;

    return 1;
}

1;
