# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::Dev::Fred::Console;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
    'Kernel::System::Log',
);

use Cwd;

=head1 NAME

Kernel::Output::HTML::Dev::Fred::Console - Dev::Fred backend module

=head1 DESCRIPTION

All Dev::Fred backend functions.

=head2 new()

create an object

    my $BackendObject = Kernel::Output::HTML::Dev::Fred::Console->new(
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

    $LayoutObject->RenderOutput(
        ModulesRef => $ModulesRef,
    );

=cut

sub RenderOutput {
    my ( $Self, %Param ) = @_;

    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');
    my $LogObject    = $Kernel::OM->Get('Kernel::System::Log');
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

    return 1 if !$Param{ModuleRef}->{Status};

    if ( $Param{ModuleRef}->{Setting} ) {
        $LayoutObject->Block(
            Name => 'Setting',
        );
    }

    my $Config           = $ConfigObject->Get('Fred')    || {};
    my $FrameworkVersion = $ConfigObject->Get('Version') || 'Version unknown';

    my $SystemName      = $Config->{'SystemName'}      || $ConfigObject->Get('Home');
    my $BackgroundColor = $Config->{'BackgroundColor'} || '#FF8A25';

    my $ModPerl       = $Self->_GetModPerl(%Param);
    my $ActiveModules = $Self->_GetActiveModules(%Param);
    my $BranchName    = $Self->_GetBranch(%Param);
    my $BranchClass;

    if ( $BranchName eq 'master' ) {
        $BranchClass = 'Warning';
    }

    $Param{ModuleRef}->{Output} = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/Console',
        Data         => {
            %{$Config},
            ActiveModules    => $ActiveModules,
            ModPerl          => $ModPerl,
            Perl             => sprintf( "%vd", $^V ),
            SystemName       => $SystemName,
            FrameworkVersion => $FrameworkVersion,
            BranchName       => $BranchName,
            BranchClass      => $BranchClass,
            BackgroundColor  => $BackgroundColor,
        },
    );

    return 1;
}

sub _GetModPerl {
    my ( $Self, %Param ) = @_;

    # find out, if modperl is used
    my $ModPerl = 'not active';

    ## no critic
    if ( exists $ENV{MOD_PERL} && defined $mod_perl::VERSION ) {
        $ModPerl = $mod_perl::VERSION;
    }
    ## use critic
    return $ModPerl;
}

sub _GetActiveModules {
    my ( $Self, %Param ) = @_;

    # create the console table
    my $ActiveModules = '<span>Activated modules:</span>';
    for my $Module ( @{ $Param{ModuleRef}->{Data} } ) {
        $ActiveModules .= "<span><strong>$Module</strong></span>";
    }
    return $ActiveModules;
}

sub _GetBranch {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $BranchName = 'could not be detected';

    # create the console table
    # Add current git branch to output
    my $Home = $ConfigObject->Get('Home');
    if ( -d "$Home/.git" ) {
        my $OldWorkingDir = getcwd();
        chdir($Home);
        my $GitResult = `git branch`;
        chdir($OldWorkingDir);

        if ($GitResult) {
            ($BranchName) = $GitResult =~ m/^[*] \s+ (\S+)/xms;
        }
    }

    return $BranchName;
}

1;
