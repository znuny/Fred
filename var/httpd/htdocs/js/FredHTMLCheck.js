"use strict";

var OTRS = Core || {};
Core.Fred = Core.Fred || {};

/**
 * @namespace
 * @exports TargetNS as Core.Fred.HTMLCheck
 * @description
 *      This namespace contains all logic for the Fred module HTMLCHeck
 */
Core.Fred.HTMLCheck = (function (TargetNS) {

    var CheckFunctions = [],
        ErrorsFound = false;

    function HTMLEncode(Text){
        return Text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
    }

    function OutputError($Element, ErrorType, ErrorDescription, Hint){
        var $Container,
            Code,
            Message;

        $('#FredHTMLCheckRunning').remove();
        ErrorsFound = true;

        // Get element HTML by wrapping it in a div and calling .html() on that
        $Container = $('<div></div>');
        $Container.append( $Element.clone() );

        Code = $Container.html();
        if (Code.length > 100) {
            Code = Code.substring(0, 100) + '...';
        }

        Message = $('<p class="Small"></p>');
        Message.append('<span class="Error">Error:</span> <strong>' + ErrorDescription + '</strong><div>' + Hint + '</div><div><code>' + HTMLEncode(Code) + '</code></div>');
        $('#FredHTMLCheckResults').append(Message);
    }

    /**
     * @function
     * @description
     *      Performs various accessibility checks to see if the HTML code
     *      violates some of our guidelines.
     * @return
     *      nothing, but calls OutputError if an error was found
     */

    function CheckAccessibility() {
        /*
         * check if input elements either have a label or an assigned title text
         */
        $('input:text, input: password, input:checkbox, input:radio, select, textarea').each(function(){
            var $this = $(this),
                $Label = $([]),
                Title;

            // first look for labels which refer to this element by id
            if ($this.attr('id') && $this.attr('id').length) {
                $Label = $('label[for=' + $this.attr('id')  + ']');
            }
            // then look for labels which surround the current element
            if (!$Label.length) {
                $Label = $this.parents('label');
            }

            if ($Label.length > 1) {
                OutputError(
                    $this,
                    'AccessibilityMultipleLabel',
                    'Input element with more than one assigned labels',
                    'Please make sure that only one label is present for this input element.'
                );
            }

            // first check if a title attribute is present, that is also ok for accessibility
            Title = $this.attr('title');
            if (Title && Title.length) {
                return;
            }

            // ok, no title available, now look for an assigned label element
            if (!$Label || !$Label.length) {
                OutputError(
                    $this,
                    'AccessibilityMissingLabel',
                    'Input element without a describing label or title attribute',
                    'Please add a title attribute or a label element with a "speaking" description for this element.'
                );
            }
        });

        /*
         * check if links have either a text or a title
         */
        $('a').each(function(){
            var $this = $(this);

            if ($this.attr('name') && !$this.attr('href')) {
                return;
            }

            if ($this.text() && $this.text().length) {
                return;
            }
            if ($this.attr('title') && $this.attr('title').length) {
                return;
            }

            OutputError(
                $this,
                'AccessibilityInaccessibleLink',
                'Link without text or title',
                'Please make sure that every link has either a text content or a title attribute that can be used by a screenreader to identify the link.'
            );

        });
    }
    CheckFunctions.push(CheckAccessibility);

    /**
     * @function
     * @description
     *      Performs various checks for bad HTML practice
     * @return
     *      nothing, but calls OutputError if an error was found
     */

    function CheckBadPractice() {
        var ObsoleteElement2Replacement,
            ObsoleteElement,
            ObsoleteClasses,
            ObsoleteClass;

        // check for inputs which should be buttons
        $('input:button, input:submit, input:reset').each(function(){
            var $this = $(this);
            OutputError(
                $this,
                'BadPracticeInputButton',
                'Old input with type button, submit or reset detected',
                'Please replace this element with a <code>&lt;button&gt;</code> with the same type. Input fields must not be used for this purpose any more.'
            );
        });

        /*
        TODO: look for a fix for chrome. In Chrome, the size attribute has a value of 20 if
            it was not specified.
        // check for inputs with size attributes
        $('input:not(:file)').each(function(){
            var $this = $(this);
            if ($this.attr('size') && $this.attr('size') > 0) {
                OutputError(
                    $this,
                    'BadPracticeInputSize',
                    'Input element with size attribute',
                    'Please remove the size attribute (this is only allowed for file upload fields). Maybe a class like W25pc, W33pc or W50pc would achieve a similar effect.'
                );
            }
        });
        */

        // check for obsolete elements
        ObsoleteElement2Replacement = {
            b: '<code>&lt;strong&gt;</code>',
            i: '<code>&lt;em&gt;</code>',
            font: '<code>&lt;span&gt;</code> with a CSS class',
            nobr: 'a proper substitute (depends on context)'
        };

        /*jslint forin: true */
        for (ObsoleteElement in ObsoleteElement2Replacement) {
            // check for inputs with size attributes
            $(ObsoleteElement).each(function(){
                var $this = $(this);
                OutputError(
                    $this,
                    'BadPracticeObsoleteElement',
                    'Obsolete element <code>&lt;' + ObsoleteElement + '&gt;</code> used',
                    'Please replace it with: ' + ObsoleteElement2Replacement[ObsoleteElement] + '.'
                );
            });
        }

        // check for obsolete classes
        ObsoleteClasses = {
            mainbody: 1,
            contentkey: 1,
            contentvalue: 1,
            searchactive: 1,
            searchpassive: 1
        };

        for (ObsoleteClass in ObsoleteClasses) {
            // check for inputs with size attributes
            $('.' + ObsoleteClass).each(function(){
                var $this = $(this);
                OutputError(
                    $this,
                    'BadPracticeObsoleteClass',
                    'Obsolete class <code>"' + ObsoleteClass + '"</code> used',
                    'Please remove it and replace it with a proper substitute.'
                );
            });
        }

        // check for events
        $("div").each(function(){

            var $this = $(this),
                $Container,
                Code,
                Events,
                Event;
            // Get element HTML by wrapping it in a div and calling .html() on that

            $Container = $('<div></div>');
            $Container.append( $this.clone() );

            Code = $Container.html();

            // search for events in html element code
            Events = Code.match(/\s+on\w+=/ig);

            // send error to output
            if (Events !== null){
                // clean leading space and equals sing from the RegEx matching
                for (Event in Events){
                    Events[Event] = Events[Event].match(/on\w+/);
                }
                // don't output this error for fred itself
                if (!$this.closest('.DevelFredContainer').length) {
                    OutputError(
                            $this,
                            'BadPracticeEvent',
                            'Event <code>"' + Events + '"</code> used',
                            'Please remove it and replace it with a proper substitute.'
                    );
                }
            }
        });

    }
    CheckFunctions.push(CheckBadPractice);

    /**
     * @function
     * @description
     *      This function checks if HTMLCheck can be started (jQuery is loaded).
     * @return nothing.
     */
    TargetNS.CheckForStart = function () {
        if (jQuery) {
            $(document).ready(function(){
                Core.Fred.HTMLCheck.Run();
            });
        }
        else {
            setTimeout(function(){
                Core.Fred.HTMLCheck.CheckForStart();
            }, 250);
        }
    };

    /**
     * @function
     * @description
     *      Runs all available check functions
     * @return
     *      nothing
     */
    TargetNS.Run = function(){
        $.each(CheckFunctions, function(){
            this();
        });
        $('#FredHTMLCheckRunning').remove();
        if (!ErrorsFound) {
            $('#FredHTMLCheckResults').html('<p class="Confirmation">All checks ok.</p>');
        }
    };

    return TargetNS;
}(Core.Fred.HTMLCheck || {}));