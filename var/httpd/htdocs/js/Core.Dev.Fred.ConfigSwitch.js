// --
// Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
// Copyright (C) 2012 Znuny GmbH, https://znuny.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --


"use strict";

var Core          = Core || {};
    Core.Dev      = Core.Dev || {};
    Core.Dev.Fred = Core.Dev.Fred || {};

/**
 * @namespace
 * @description
 *      This namespace contains all logic for the Fred module ConfigSwitch
 */
Core.Dev.Fred.ConfigSwitch = (function (TargetNS) {

    TargetNS.Init = function(){

        Core.App.Ready(function(){
            $('.FredSwitch a').unbind('click').bind('click', function() {

                var Key = $(this).data('key'),
                    Value = parseInt($(this).data('value'), 10),
                    Data = {};

                if (!Key) {
                    return false;
                }

                $(this).parent().toggleClass('On');

                $(this).parent().next('td').prepend('<i class="fa fa-circle-o-notch fa-spin"></i>&nbsp;');

                Data = {
                    Action: 'Fred',
                    Subaction: 'ConfigSwitchAJAX',
                    'Key': Key,
                    'Value': Value
                };

                Core.AJAX.FunctionCall(
                    Core.Config.Get('Baselink'),
                    Data,
                    function() {
                        location.reload(true);
                    },
                    'json'
                );

                return false;

            });
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Dev.Fred.ConfigSwitch || {}));
