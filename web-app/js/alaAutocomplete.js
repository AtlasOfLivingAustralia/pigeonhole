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

// Requires Bootstrap 2.3.2 and TypeAhead (http://twitter.github.io/typeahead.js)

var bieJson = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    //prefetch: '../data/films/post_1960.json',
    remote: {
        url: 'http://bie.ala.org.au/search/auto.jsonp?q=%QUERY',
        filter: function (resp) {
            var results = [];
            $.each(resp.autoCompleteList, function(i, el) {
                if (el.matchedNames.length > 0) {
                    results.push({name: el.matchedNames[0] });
                } else {
                    results.push({name: el.name });
                }
            });
            //return resp.autoCompleteList;
            return results;
        },
        ajax: { dataType: 'jsonp' }}
});

bieJson.initialize();

var ta = $('.typeahead').typeahead(null, {
    name: 'species-lookup',
    displayKey: 'name',
    source: bieJson.ttAdapter()
}).on('typeahead:autocompleted typeahead:selected', function (obj, datum) {
    //console.log('typeahead:autocompleted', obj, datum);
    $('#guid').val(datum.guid);
}).on('typeahead:cursorchanged', function () {
    //console.log('typeahead:cursorchanged');
    $('#guid').val('');
});
$('.twitter-typeahead').addClass('form-control');
$('.tt-dropdown-menu').width($('.typeahead').width());