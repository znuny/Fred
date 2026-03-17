// --
// Copyright (C) 2001-2021 OTRS AG, http://otrs.com/
// Copyright (C) 2012 Znuny GmbH, https://znuny.com/
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

var Core     = Core || {};
Core.Dev     = Core.Dev || {};
Core.Dev.Fred = Core.Dev.Fred || {};

/**
 * @namespace
 * @description
 *      This namespace contains all logic for the Fred module SQLLog
 */
Core.Dev.Fred.SQLLog = (function (TargetNS) {

    TargetNS.Init = function(){
        Core.App.Ready(function(){
            $('a.ShowBindParameters').unbind('click').bind('click', function() {
                $(this).hide().parent().find('div').show();
            });
        });
    };

    Core.Init.RegisterNamespace(TargetNS, 'APP_MODULE');

    return TargetNS;
}(Core.Dev.Fred.SQLLog || {}));
