# --
# Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::TranslationLog;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::Dev::Fred::TranslationLog - Dev::Fred backend module

=head1 DESCRIPTION

All Dev::Fred backend functions.

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::TranslationLog->new(
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

creates the output of the translation debugging log

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

    my $HTMLLines = '';
    for my $Line ( @{ $Param{ModuleRef}->{Data} } ) {
        $HTMLLines .= "<span>$Line</span>";
    }

    return 1 if !$HTMLLines;

    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/TranslationLog',
        Data         => {
            HTMLLines => $HTMLLines,
        },
    );

    return 1;
}

1;
