# --
# Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::EnvLog;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::Dev::Fred::EnvLog - Dev::Fred backend module

=head1 DESCRIPTION

Show log of the environment ref, data for $Env in dtl

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::EnvLog->new(
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

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    NEEDED:
    for my $Needed (qw(ModuleRef)) {

        next NEEDED if defined $Param{$Needed};
        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    # Kernel::System::Dev::Fred::EnvLog::DataGet() is not used,
    # as the data of interest is not easily available there.
    for my $Key ( sort keys %{ $LayoutObject->{EnvRef} } ) {

        $LayoutObject->Block(
            Name => 'EnvDataRow',
            Data => {
                Key   => $Key,
                Value => $LayoutObject->{EnvRef}->{$Key},
            },
        );
    }

    # output the html
    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/EnvLog',
    );

    return 1;
}

1;
