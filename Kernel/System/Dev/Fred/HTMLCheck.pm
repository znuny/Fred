# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::HTMLCheck;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

our @ObjectDependencies = ();

=head1 NAME

Kernel::System::Dev::Fred::HTMLCheck

=head1 DESCRIPTION

handle the config log data

=cut

=head2 DataGet()

    $BackendObject->DataGet(
        ModuleRef => $ModuleRef,
    );

=cut

sub DataGet {
    return 1;
}

1;
