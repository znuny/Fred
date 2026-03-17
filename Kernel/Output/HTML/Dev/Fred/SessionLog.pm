# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::SessionLog;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::AuthSession',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::Dev::Fred::SessionLog - Dev::Fred backend module

=head1 DESCRIPTION

All Dev::Fred backend functions.

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::SessionLog->new(
        %Param,
    );

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

=head2 RenderOutput()

Get the session data and create the output of the session log

    $BackendObject->RenderOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub RenderOutput {
    my ( $Self, %Param ) = @_;

    my $LogObject     = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject  = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $SessionObject = $Kernel::OM->Get('Kernel::System::AuthSession');

    NEEDED:
    for my $Needed (qw(ModuleRef)) {

        next NEEDED if defined $Param{$Needed};
        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    # Data is generated here, as it is not available in Kernel::System::Dev::Fred::SessionLog
    my $SessionID = $LayoutObject->{EnvRef}->{SessionID};
    my %SessionData;
    if ($SessionID) {
        %SessionData = $SessionObject->GetSessionIDData( SessionID => $SessionID );
    }

    for my $Key ( sort keys %SessionData ) {

        $LayoutObject->Block(
            Name => 'SessionDataRow',
            Data => {
                Key   => $Key,
                Value => $SessionData{$Key},
            },
        );
    }

    # output the html
    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/SessionLog',
    );

    return 1;
}

1;
