# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::ConfigSwitch;
use parent qw(Kernel::System::Dev::Fred::Base);

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
);

=head1 NAME

Kernel::System::Dev::Fred::ConfigSwitch

=head1 DESCRIPTION

handle the config log data

=cut

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
    my $Config       = $ConfigObject->Get('Fred')->{'Module'}->{'ConfigSwitch'}->{'Config'};

    return if !$Config->{Settings};
    my @ConfigItems;
    for my $Item ( sort @{ $Config->{Settings} } ) {
        my $Value = $ConfigObject->Get($Item);
        push @ConfigItems, {
            Key   => $Item,
            Value => $Value,
        };
    }

    $Param{ModuleRef}->{Data} = \@ConfigItems;

    return 1;
}

1;
