# --
# Copyright (C) 2001-2021 OTRS AG, https://otrs.com/
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --
## nofilter(TidyAll::Plugin::Znuny::CodeStyle::STDERRCheck)

package Kernel::Output::HTML::FilterContent::Dev::Fred;

use strict;
use warnings;
use utf8;
use URI::Escape;

our @ObjectDependencies = (
    'Kernel::Config',
    'Kernel::Output::HTML::Layout',
);

=head1 NAME

Kernel::Output::HTML::FilterContent::Dev::Fred

=head1 SYNOPSIS

a output filter module specially for developer

=head1 PUBLIC INTERFACE

=head2 new()

Don't use the constructor directly.

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');
    my $LayoutObject = $Kernel::OM->Get('Kernel::Output::HTML::Layout');

    my $Config = $ConfigObject->Get('Fred');
    return 1 if !$Config->{Active};

    # perhaps no output is generated
    die 'Fred: At the moment, your code generates no output!' if !$Param{Data};

    # do not show the debug bar in Fred's setting window
    if ( $LayoutObject->{Action} && $LayoutObject->{Action} eq 'Fred' ) {
        return 1;
    }

    # do nothing if output is an attachment download or AJAX request
    if (
        ${ $Param{Data} } =~ /^Content-Disposition: attachment;/mi
        || ${ $Param{Data} } =~ /^Content-Disposition: inline;/mi
        )
    {
        return 1;
    }

    # do nothing if it is a redirect
    if (
        ${ $Param{Data} } =~ /^Status: 302 Moved/mi
        && ${ $Param{Data} } =~ /^location:/mi
        && length( ${ $Param{Data} } ) < 800
        )
    {
        print STDERR "REDIRECT\n";
        return 1;
    }

    # do nothing if it is Fred it self
    if ( ${ $Param{Data} } =~ m{Fred-Setting<\/title>}msx ) {
        print STDERR "CHANGE Fred SETTING\n";
        return 1;
    }

    # do nothing if it does not contain the <html> element, might be
    # an embedded layout rendering
    if ( ${ $Param{Data} } !~ m{<html[^>]*>}msx ) {
        return 1;
    }

    # get data of the activated modules
    my %ModuleForRef = %{ $Config->{'Module'} || {} };
    $ModuleForRef{'Console'}->{Prio} = '99999';

    my $ModulesDataRef = {};
    my $PrioCounter    = 9000;

    MODULE:
    for my $Module ( sort keys %ModuleForRef ) {
        next MODULE if $ModuleForRef{$Module}->{Prio};
        $ModuleForRef{$Module}->{Prio} = $PrioCounter;
        $PrioCounter++;
    }

    MODULE:
    for my $Module ( sort { $ModuleForRef{$a}->{Prio} <=> $ModuleForRef{$b}->{Prio} } keys %ModuleForRef ) {

        next MODULE if !$ModuleForRef{$Module}->{Active};
        $ModulesDataRef->{$Module} = {};
        $Kernel::OM->Get( 'Kernel::System::Dev::Fred::' . $Module )->DataGet(
            ModuleRef      => $ModulesDataRef->{$Module},
            HTMLDataRef    => $Param{Data},
            FredModulesRef => $ModulesDataRef,
        );

        $Kernel::OM->Get( 'Kernel::Output::HTML::Dev::Fred::' . $Module )->RenderOutput(
            ModuleRef => $ModulesDataRef->{$Module},
        );
        $ModulesDataRef->{$Module}->{Prio} = $ModuleForRef{$Module}->{Prio};
    }

    # build the content string
    my $Output = '';
    if ( $ModulesDataRef->{Console}->{Output} ) {
        $Output .= $ModulesDataRef->{Console}->{Output};
        delete $ModulesDataRef->{Console};
    }

    for my $Module ( sort { $ModulesDataRef->{$a}->{Prio} <=> $ModulesDataRef->{$b}->{Prio} } keys %{$ModulesDataRef} )
    {
        $Output .= $ModulesDataRef->{$Module}->{Output} || '';
    }

    # put output in the Fred Container
    $Output = $LayoutObject->Output(
        TemplateFile => 'Dev/Fred/Container',
        Data         => {
            Data => $Output
        },
    );

    # include the fred output in the original output
    if ( ${ $Param{Data} } !~ s/(\<body(|.+?)\>)/$1\n$Output\n\n\n\n/mx ) {
        ${ $Param{Data} } =~ s/^(.)/\n$Output\n\n\n\n$1/mx;
    }

    return if !$LayoutObject->{UserID};

    # add fred icon to header
    my $Active = $Config->{'Active'} || 0;
    my $Class  = $Active ? 'FredActive' : '';
    my $Title  = $LayoutObject->{LanguageObject}->Translate('Fred Console');

    ${ $Param{Data} } =~ s{ <div [^>]* id="header" [^>]*> }{
        $&
        <div class="FredToggleContainer">
            <a id="FredToggleContainerLink" class="icon-hover-md $Class" href="#" title="$Title"><i class="fa fa-bug"></i></a>
        </div>
    }xmsig;

    # activate Fred with class='FredActive'
    ${ $Param{Data} } =~ s{ (<body [^>]* class=" [^"]*) ( " [^>]*> ) }{ $1 $Class $2 }xmsig;

    return 1;
}

1;
