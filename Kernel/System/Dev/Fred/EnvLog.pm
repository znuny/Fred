# --
# Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::EnvLog;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::System::Log',
);

=head1 NAME

Kernel::System::Dev::Fred::EnvLog


=head1 DESCRIPTION

handle the config log data

=cut

=head2 DataGet()

This method is just for compatibility. No data is set here,
as the needed session object is not easily available here.

    my $DataGetOk = $BackendObject->DataGet(
        ModuleRef => $ModuleRef,
    );

=cut

sub DataGet {
    my ( $Self, %Param ) = @_;

    my $LogObject = $Kernel::OM->Get('Kernel::System::Log');

    NEEDED:
    for my $Needed (qw(ModuleRef)) {

        next NEEDED if defined $Param{$Needed};

        $LogObject->Log(
            Priority => 'error',
            Message  => "Need $Needed!",
        );
        return;
    }

    return 1;
}

1;
