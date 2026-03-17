# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::Dev::Fred::Base;

use strict;
use warnings;
use utf8;

our @ObjectDependencies = (
    'Kernel::Config',
);

=head1 NAME

Kernel::System::Dev::Fred::Base

=head1 DESCRIPTION

handle with base Fred functions

=cut

=head2 new()

create an object

=cut

sub new {
    my ( $Type, %Param ) = @_;

    my $Self = {};
    bless( $Self, $Type );

    $Self->{Name} = $Type;
    $Self->{Name} =~ s{Kernel::System::Dev::Fred::}{}smx;

    my $ConfigObject = $Kernel::OM->Get('Kernel::Config');

    my $Config = $ConfigObject->GetOriginal('Fred') || {};

    $Self->{Home}        = $ConfigObject->GetOriginal('Home');
    $Self->{LogPath}     = $Config->{LogPath} || '/var/log/dev/Fred/';
    $Self->{LogFileName} = "$Self->{Name}.log";

    my $ModuleInit = $Self->Init();

    if (
        ref $Config->{Module}
        && $Config->{Module}->{ $Self->{Name} }
        )
    {
        %{ $Config->{Module}->{ $Self->{Name} } } = (
            %{ $Config->{Module}->{ $Self->{Name} } },
            %{ $ModuleInit || {} },
        );

        $Self->{Active}      = $Config->{Module}->{ $Self->{Name} }->{Active};
        $Self->{Config}      = $Config->{Module}->{ $Self->{Name} }->{Config};
        $Self->{LogFileName} = $Config->{Module}->{ $Self->{Name} }->{LogFileName} || $Self->{LogFileName};
    }

    $Self->{LogFile} = $Self->{Home} . $Self->{LogPath} . $Self->{LogFileName};

    return $Self;
}

=head2 Init()

    $BackendObject->Init();

=cut

sub Init {
    my ( $Self, %Param ) = @_;
    my %Config;

    return \%Config;
}

=head2 DataGet()

    $BackendObject->DataGet(
        ModuleRef => $ModuleRef,
    );

=cut

sub DataGet {
    my ( $Self, %Param ) = @_;

    return 1 if !$Self->{Active};
    return 1;
}

=head2 InsertWord()

    $BackendObject->InsertWord(
        What => 'a word',
    );

=cut

sub InsertWord {
    my ( $Self, %Param ) = @_;

    return 1 if !$Self->{Active};
    return 1;
}

1;
