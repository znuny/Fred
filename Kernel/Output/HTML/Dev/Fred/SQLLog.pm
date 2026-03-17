# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::SQLLog;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

=head1 NAME

Kernel::Output::HTML::Dev::Fred::SQLLog - Dev::Fred backend module

=head1 DESCRIPTION

All Dev::Fred backend functions.

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::ConfigLog->new(
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

creates the output of the SQL log

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

    my @SQLLog;

    for my $Line ( @{ $Param{ModuleRef}->{Data} } ) {

        my %SQLLogEntry = (
            Time            => $Line->[4] * 1000,
            EqualStatements => $Line->[5] || '',
            Statement       => $Line->[1],
            Package         => $Line->[3],
            BindParameters  => $Line->[2],
        );

        for my $Line ( split( /;/, $Line->[3] ) ) {
            $SQLLogEntry{StackTrace} //= [];
            push @{ $SQLLogEntry{StackTrace} }, $Line;
        }

        push @SQLLog, \%SQLLogEntry;
    }

    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/SQLLog',
        Data         => {
            AllStatements    => $Param{ModuleRef}->{AllStatements},
            DoStatements     => $Param{ModuleRef}->{DoStatements},
            SelectStatements => $Param{ModuleRef}->{SelectStatements},
            Time             => $Param{ModuleRef}->{Time},
            SQLLog           => \@SQLLog,
        },
    );

    return 1;
}

1;
