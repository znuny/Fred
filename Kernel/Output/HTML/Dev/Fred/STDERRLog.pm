# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::STDERRLog;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::Dev::Fred::STDERRLog - Dev::Fred backend module

=head1 DESCRIPTION

All Dev::Fred backend functions.

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::STDERRLog->new(
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

creates the output of the STDERR log

    $BackendObject->RenderOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub RenderOutput {
    my ( $Self, %Param ) = @_;

    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    NEEDED:
    for my $Needed (qw(ModuleRef)) {

        next NEEDED if defined $Param{$Needed};
        $LogObject->Log(
            Priority => 'error',
            Message  => "Parameter '$Needed' is needed!",
        );
        return;
    }

    return if !$Param{ModuleRef}->{Data};
    return if ref $Param{ModuleRef}->{Data} ne 'ARRAY';

    my $Module = $ConfigObject->Get('Fred')->{Module}->{STDERRLog} || {};

    # create html string
    my $HTMLLines;
    my $HTMLLinesFilter = $Module->{Config}->{Filter};

    LINE:
    for my $Line ( reverse @{ $Param{ModuleRef}->{Data} } ) {

        # filter content if needed
        if ($HTMLLinesFilter) {
            next LINE if $Line =~ /$HTMLLinesFilter/smx;
        }

        $HTMLLines .= $Line;
    }

    return if !$HTMLLines;

    # output the html
    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/STDERRLog',
        Data         => {
            HTMLLines => $HTMLLines,
        },
    );

    return 1;
}

1;
