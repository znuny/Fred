# --
# Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::Console;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Dev::Fred::Console

=head1 DESCRIPTION

handle the config log data

=cut

=head2 DataGet()

Get the data for this Fred module. Returns true or false.
And adds the data to the module ref.

    $BackendObject->DataGet(
        ModuleRef => $ModuleRef,
    );

=cut

sub DataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    NEEDED:
    for my $Needed (qw(ModuleRef HTMLDataRef FredModulesRef)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!",
        );
        return;
    }

    my @Modules;
    MODULE:
    for my $Module ( sort keys %{ $Param{FredModulesRef} } ) {
        next MODULE if $Module eq 'Console';
        push @Modules, $Module;
    }

    $Param{ModuleRef}->{Data} = \@Modules;

    if ( ${ $Param{HTMLDataRef} } !~ m/Fred-Setting/ && ${ $Param{HTMLDataRef} } =~ /\<body.*?\>/ )
    {
        $Param{ModuleRef}->{Status} = 1;
    }

    if ( ${ $Param{HTMLDataRef} } !~ m/name="Action" value="Login"/ ) {
        $Param{ModuleRef}->{Setting} = 1;
    }

    return 1;
}

1;
