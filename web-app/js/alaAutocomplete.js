/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */
// jQuery style plugin for ALA autocomplete on BIE names
//
// Requires Bootstrap 2.3.2 and TypeAhead (http://twitter.github.io/typeahead.js)

(function($){
    if (!$.alaAutocomplete) { // check the plugin namespace does not already exist
        // call with $('#foo').alaAutocomplete({})
        $.fn.alaAutocomplete = function (options) {
            var $this = this;

            // This is the easiest way to have default options.
            var settings = $.extend({
                // These are the defaults.
                guidSelector: "#guid",
                nameSelector: "#scientificName",
                maxHits: 10,
                url: 'http://bie.ala.org.au/ws/search/auto.jsonp'
            }, options );

            //console.log('alaAutocomplete',settings, $this.attr('type'));

            var bieJson = new Bloodhound({
                datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
                queryTokenizer: Bloodhound.tokenizers.whitespace,
                limit: settings.maxHits,
                //prefetch: '../data/films/post_1960.json',
                remote: {
                    wildcard: '%QUERY',
                    url: settings.url + '?limit=' + settings.maxHits + '&q=%QUERY',
                    filter: function (resp) {
                        var results = [];
                        $.each(resp.autoCompleteList, function (i, el) {
                            if (el.matchedNames.length > 0) {
                                results.push({name: el.matchedNames[0], sciname: el.name, guid: el.guid });
                            } else {
                                results.push({name: el.name, sciname: el.name, guid: el.guid });
                            }
                        });
                        //return resp.autoCompleteList;
                        return results;
                    },
                    ajax: { dataType: 'jsonp' }}
            });

            bieJson.initialize();

            var ta = $($this).typeahead(null, {
                name: 'species-lookup',
                displayKey: 'name',
                source: bieJson.ttAdapter()
            }).on('typeahead:autocompleted typeahead:selected', function (obj, datum) {
                //console.log('typeahead:autocompleted', obj, datum);
                $(settings.guidSelector).val(datum.guid).change();
                $(settings.nameSelector).val(datum.sciname).change();
            }).on('typeahead:cursorchanged', function () {
                //console.log('typeahead:cursorchanged');
                $(settings.guidSelector).val('');
                $(settings.nameSelector).val('');
            });

            jQuery('.twitter-typeahead').addClass('form-control'); // fix for grouped buttons
            $('.tt-dropdown-menu').width($('.typeahead').width()); // fix for grouped buttons

            // add a reset method to clear the autocomplete input
            $.fn.alaAutocomplete.reset = function() {
                //console.log('reset typeahead');
                ta.typeahead('val', '');
                //$($this).trigger('blur');
                //$('.tt-input').val('');
            };

            return $this; // for chaining;
        };
    }
})(jQuery);