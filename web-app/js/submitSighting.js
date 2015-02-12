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

/*  Global var GSP_VARS required to be set in calling page */

$(document).ready(function() {
    if (typeof GSP_VARS == 'undefined') {
        alert('GSP_VARS not set in page - required for submit.js');
    }
    // upload code taken from http://blueimp.github.io/jQuery-File-Upload/basic-plus.html
    var imageCount = 0;

    $('#fileupload').fileupload({
        url: GSP_VARS.uploadUrl,
        dataType: 'json',
        autoUpload: true,
        acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
        maxFileSize: 5000000, // 5 MB
        // Enable image resizing, except for Android and Opera,
        // which actually support image resizing, but fail to
        // send Blob objects via XHR requests:
        disableImageResize: /Android(?!.*Chrome)|Opera/
            .test(window.navigator.userAgent),
        previewMaxWidth: 100,
        previewMaxHeight: 100,
        previewCrop: true
    }).on('fileuploadadd', function (e, data) {
        // load event triggered (start)
        // Clone the template and reference it via data.context
        data.context = $('#uploadActionsTmpl').clone(true).removeAttr('id').removeClass('hide').appendTo('#files');
        $.each(data.files, function (index, file) {
            var node = $(data.context[index]);
            node.find('.filename').append(file.name + '  (' + humanFileSize(file.size) + ')');
            node.data('index', imageCount++);
            $('#imageLicenseDiv').removeClass('hide'); // show the license options
        });
    }).on('fileuploadprocessalways', function (e, data) {
        // next event after 'add' setup progress bar, etc
        var index = data.index,
            file = data.files[index],
            hasMetaData = false,
            node = $(data.context[index]); // grab the current image node (created via a template)
        if (file.preview) {
            // add preview image
            node.find('.preview').append(file.preview);
        }

        if (data.exif) {
            // add EXIF data (date, location, etc)
            // console.log('exif tags', data.exif, data.exif.getAll());
            // GPS coordinates are in deg/min/sec -> convert to decimal
            var lat = data.exif.getText('GPSLatitude'); // getText returns "undefined" as a String if not set!
            var lng = data.exif.getText('GPSLongitude'); // getText returns "undefined" as a String if not set!

            if (lat != "undefined" && lng != "undefined") {
                // add GPS data
                lat = lat.split(',');
                lng = lng.split(',');
                var latRef = data.exif.getText('GPSLatitudeRef') || "N";
                var lngRef = data.exif.getText('GPSLongitudeRef') || "W";
                lat = ((Number(lat[0]) + Number(lat[1])/60 + Number(lat[2])/3600) * (latRef == "N" ? 1 : -1)).toFixed(10);
                lng = ((Number(lng[0]) + Number(lng[1])/60 + Number(lng[2])/3600) * (lngRef == "W" ? -1 : 1)).toFixed(10);
                hasMetaData = true;
                node.find('.imgCoords').empty().append(lat + ", " + lng).data('lat',lat).data('lng',lng);
            }

            var dateTime = (data.exif.getText('DateTimeOriginal') != 'undefined') ? data.exif.getText('DateTimeOriginal') : null;// || data.exif.getText('DateTime');
            var gpsDate = (data.exif.getText('GPSDateStamp') != 'undefined') ? data.exif.getText('GPSDateStamp') : null;
            var gpsTime = (data.exif.getText('GPSTimeStamp') != 'undefined') ? data.exif.getText('GPSTimeStamp') : null;

            if (gpsTime && dateTime) {
                // determine local time offset from UTC
                // by working out difference between DateTimeOriginal and GPSTimeStamp to get timezone (offset)
                // gpsDate is not always set - if absent assume same date as 'DateTimeOriginal'
                var date = gpsDate || dateTime.substring(0,10); //dateTime.substring(0,10)
                date = date.replace(/:/g,'-') + ' ' + parseGpsTime(gpsTime); // comvert YYYY:MM:DD to YYYY-MM-DD
                var gpsMoment = moment(date);
                var datetimeTemp = parseExifDateTime(dateTime, false);
                var localMoment = moment(datetimeTemp);
                var gpsDiff = localMoment.diff(gpsMoment, 'minutes');
                var prefix = (gpsDiff >= 0) ? '+' : '';
                gpsDiff = Math.round(gpsDiff / 10) * 10; // round to nearest 10 min (for minor discrepancies in time in EXIF data)
                var gpsOffset = prefix + moment.duration(gpsDiff, 'minutes').format("hh:mm");
                $('#timeZoneOffset').val(gpsOffset);
                hasMetaData = true;
            }
            if (dateTime) {
                // add date & time
                hasMetaData = true;
                var isoDateStr = parseExifDateTime(dateTime, true) || dateTime;
                node.find('.imgDate').html(isoDateStr);
                if (! node.find('.imgDate').data('datetime')) {
                    node.find('.imgDate').data('datetime', isoDateStr);
                }
            } else if (gpsDate) {
                hasMetaData = true;
                var isoDateStr = gpsDate.replace(/:/g,'-');
                node.find('.imgDate').html(isoDateStr);
                if (! node.find('.imgDate').data('datetime')) {
                    node.find('.imgDate').data('datetime', isoDateStr);
                }
            }

            if (hasMetaData) {
                // activate the button
                node.find('.imageData').removeAttr('disabled').attr('title','Use image date/time & GPS coordinates for this sighting');
            }
        }
        if (file.error) {
            node.find('.error').append($('<span class="text-danger"/>').text(file.error));
        }
    }).on('fileuploadprogressall', function (e, data) {
        // progress metre - gets triggered mulitple times
        var progress = parseInt(data.loaded / data.total * 100, 10);
        $('#progress .progress-bar').css(
            'width',
            progress + '%'
        );
    }).on('fileuploaddone', function (e, data) {
        // file has successfully uploaded
        var node = $(data.context[0]);
        var index = node.data('index');
        var result = data.result; // ajax results
        if (result.success) {
            var link = $('<a>')
                .attr('target', '_blank')
                .prop('href', result.url);
            node.find('.preview').wrap(link);
            // populate hidden input fields
            node.find('.identifier').val(result.url).attr('name', 'multimedia['+ index + '].identifier');
            node.find('.title').val(result.filename).attr('name', 'multimedia['+ index + '].title');
            node.find('.format').val(result.mimeType).attr('name', 'multimedia['+ index + '].format');
            node.find('.creator').val((GSP_VARS.user && GSP_VARS.user.userDisplayName) ? GSP_VARS.user.userDisplayName : 'ALA User').attr('name', 'multimedia['+ index + '].creator');
            node.find('.license').val($('#imageLicense').val()).attr('name', 'multimedia['+ index + '].license');
            if (result.exif && result.exif.date) {
                node.find('.created').val(result.exif.date).attr('name', 'multimedia['+ index + '].created');
            }
            insertImageMetadata(node);
        } else if (data.error) {
            // in case an error still returns a 200 OK... (our service shouldn't)
            var error = $('<div class="alert alert-error"/>').text(data.error);
            node.append(error);
        }
    }).on('fileuploadfail', function (e, data) {
        $.each(data.files, function (index, file) {
            var error = $('<div class="alert alert-error"/>').text('File upload failed.');
            $(data.context.children()[index]).append(error);
        });
    }).prop('disabled', !$.support.fileInput)
        .parent().addClass($.support.fileInput ? undefined : 'disabled');

    // pass in local time offset from UTC
    var offset = new Date().getTimezoneOffset() * -1;
    var hours = offset / 60;
    var minutes = offset % 60;
    var prefix = (hours >= 0) ? '+' : '';
    $('#timeZoneOffset').val(prefix + ('0' + hours).slice(-2) + ':' + ('0' + minutes).slice(-2));

    // use image data button
    $('#files').on('click', 'button.imageData', function() {
        insertImageMetadata($(this).parents('.imageRow'));
        return false;
    });

    // remove image button
    $('#files').on('click', 'button.imageRemove', function() {
        $(this).parents('.imageRow').remove();
    });

    // image license drop-down
    $('#imageLicense').change(function() {
        $('input.license').val($(this).val());
    });

    // Clear the #eventDateNoTime field (extracted from photo EXIF data) if user changes either the date or time field
    $('#eventDateNoTime, #eventTime').keyup(function() {
        $('#eventDateTime').val('');
    });

    // close button on bootstrap alert boxes
    $("[data-hide]").on("click", function(){
        $(this).closest("." + $(this).attr("data-hide")).hide();
        clearTaxonDetails();
    });

    // species group drop-down
    var speciesGroupsObj = GSP_VARS.speciesGroups;
    $('#speciesGroups').change(function(e) {
        var group = $(this).val();
        var noSelectOpt = '-- Choose a sub group --';
        $('#speciesSubgroups').empty().append($("<option/>").attr("value","").text(noSelectOpt));

        if (group) {
            $.each(speciesGroupsObj[group], function(i, el) {
                $('#speciesSubgroups')
                    .append($("<option/>")
                        .attr("value",el.common)
                        .text(el.common));
            });
            addTagLabel(group);
            $('#browseSpecesImages').removeClass('disabled').removeAttr('disabled');
        } else {
            $('#browseSpecesImages').addClass('disabled').attr('disabled','');
        }
    });

    // species subgroup drop-down
    $('#speciesSubgroups').change(function(e) {
        addTagLabel($(this).val());
    });

    // remove species/secientificName box
    $('#species').on('click', 'a.remove', function(e) {
        e.preventDefault();
        $(this).parent().hide();
    });

    // autocomplete on species lookup
    $('#speciesLookup').alaAutocomplete({maxHits: 15}); // will trigger a change event on #taxonConceptID when item is selected

    // detect change on #taxonConceptID input (autocomplete selection) and load species details
    $('#guid').change(function(e) {
        $('#speciesLookup').alaAutocomplete.reset();
        var guid = $(this).val();

        if (guid) {
            $.getJSON(GSP_VARS.bieBaseUrl + "/ws/species/shortProfile/" + guid + ".json?callback=?")
                .done(function(data) {
                    if (data.scientificName) {
                        $('#taxonDetails').removeClass('hide').show();

                        $('.sciName a').attr('href', GSP_VARS.bieBaseUrl + "/species/" + guid).html(data.scientificName);
                        $('.speciesThumbnail').attr('src', GSP_VARS.bieBaseUrl + '/ws/species/image/thumbnail/' + guid);
                        if (data.commonName) {
                            $('.commonName').text(data.commonName);
                            $('#commonName').val(data.commonName);
                        } else {
                            //$('.commonName').hide();
                        }
                        $('#noTaxa').hide();
                        $('#matchedTaxa').show();
                        $('#identificationChoice').show();
                    }
                })
                .fail(function( jqXHR, textStatus, errorThrown ) {
                    alert("Error: " + textStatus + " - " + errorThrown);
                })
                .always(function() {
                    // clean-up & spinner deactivations, etc
                });
        }

    });

    // update map in edit mode
    if (GSP_VARS.sightingBean.decimalLongitude) {
        // trigger map to refresh
        $('#decimalLongitude').change();
    }

    // show tags in edit mode
    var tags = (GSP_VARS.sightingBean.tags) ? GSP_VARS.sightingBean.tags : [];
    $.each(tags, function(i, t) {
        addTagLabel(t);
    });

    // show images in edit mode
    var media = (GSP_VARS.sightingBean.multimedia) ? GSP_VARS.sightingBean.multimedia : [];
    $.each(media, function(i, m) {
        // console.log("image", m);
        addServerImage(m, i);
    });

    // init date picker
    $('#eventDateNoTime').datepicker({format: 'dd-mm-yyyy'});

    // clear validation errors red border on input blur
    $('.validationErrors').on('blur', function(e) {
        $(this).removeClass('validationErrors');
    });

    // click event on confidence button group
    $('#confidentZ#uncertain').click(function(e) {
        e.preventDefault();
        var $this = this;
        var highlightClass = 'btn-inverse';
        $('#confident, #uncertain').removeClass(highlightClass);
        //$('#showConfident, #showUncertain').addClass('hide');
        $($this).addClass(highlightClass);
        //$('#speciesMisc').removeClass('hide')
        if ($($this).attr('id') == 'confident') {
            //$('#showConfident').removeClass('hide');
            $('#identificationVerificationStatus').val('Confident');
            $('#requireIdentification').prop('checked', false);
        } else {
            //$('#showUncertain').removeClass('hide');
            $('#identificationVerificationStatus').val('Uncertain');
            $('#requireIdentification').prop('checked', true);
        }
    });

    // load species info if id is in the URL
    if (GSP_VARS.guid) {
        $('#guid').val(GSP_VARS.guid).change();
        $('#confident').trigger( "click" );
    }

    // init qtip (tooltip)
    $('.tooltips').qtip({
        style: {
            classes: 'ui-tooltip-rounded ui-tooltip-shadow'
        },
        position: {
            target: 'mouse',
            adjust: { x: 6, y: 14 }
        }
    });

    // save location as bookmark button click event
    $('#bookmarkLocation').click(function(e) {
        e.preventDefault();
        //$.getJSON(GSP_VARS.bookmarksUrl)
        //.done(function(data) {
        //    if (data.scientificName) {
        //        // populate drop-down
        //    }
        //})
        //.fail(function( jqXHR, textStatus, errorThrown ) {
        //    alert("Error: " + textStatus + " - " + errorThrown);
        //})
        //.always(function() {
        //    // clean-up & spinner deactivations, etc
        //});
    });

    console.log("moment check", moment().format("DD-MM-YYYY"));
    testMoment()

}); // end of $(document).ready(function()

function testMoment() {
    console.log("moment check", moment().format("DD-MM-YYYY HH:mm"));
}

function insertImageMetadata(imageRow) {
    // imageRow is a jQuery object
    var dateTime = String(imageRow.find('.imgDate').data('datetime'));
    if (dateTime) {
        $('#eventDateTime').val(dateTime);
        $('#eventDateNoTime').val(isoToAusDate(dateTime.substring(0,10)));
        $('#eventTime').val(dateTime.substring(11,19));
        $('#timeZoneOffset').val(dateTime.substring(19));
        console.log("dateTime 3.1", dateTime, dateTime instanceof String);
        var mDateTime = moment(dateTime, moment.ISO_8601); // format("DD-MM-YYYY, HH:mm");
        $('#eventDate_year').val(mDateTime.format("YYYY"));
        $('#eventDate_month').val(mDateTime.format("M"));
        $('#eventDate_day').val(mDateTime.format("D"));
        $('#eventDate_hour').val(mDateTime.format("HH"));
        $('#eventDate_minute').val(mDateTime.format("mm"));
    }
    var lat = imageRow.find('.imgCoords').data('lat');
    var lng = imageRow.find('.imgCoords').data('lng');
    if (lat && lng) {
        $('#decimalLatitude').val(lat).change();
        $('#decimalLongitude').val(lng).change();
        $('#georeferenceProtocol').val('camera/phone');
    }
}

function isoToAusDate(isoDate) {
    var dateParts = isoDate.substring(0,10).split('-');
    var ausDate = isoDate.substring(0,10); // fallback

    if (dateParts.length == 3) {
        ausDate = dateParts.reverse().join('-');
    }

    return ausDate;
}

function clearTaxonDetails() {
    $('#taxonDetails .commonName').html('');
    $('#taxonDetails img').attr('src','');
    $('#taxonDetails a').attr('href','').html('');
    $('#taxonConceptID, #scientificName, #commonName').val('');
}

/**
 * Adds a visual tag (label/badge) to the page when either group/subgroup select changes
 *
 * @param group
 */
function addTagLabel(group) {
    if (group) {
        var close = '<a href="#" class="remove" title="remove this item"><i class="remove icon-remove icon-white">&nbsp;</i></a>';
        var input = '<input type="hidden" value="' + group + '" name="tags"/>';
        var label = $('<span class="label label-infoX"/>').append(input + group + close).after('&nbsp;');
        $('#tagsBlock').append(label);
    }
}

/**
 * Convert bytes to human readable form.
 * Taken from http://stackoverflow.com/a/14919494/249327
 *
 * @param bytes
 * @param si
 * @returns {string}
 */
function humanFileSize(bytes, si) {
    var thresh = si ? 1000 : 1024;
    if(bytes < thresh) return bytes + ' B';
    //var units = si ? ['kB','MB','GB','TB','PB','EB','ZB','YB'] : ['KiB','MiB','GiB','TiB','PiB','EiB','ZiB','YiB'];
    var units =  ['kB','MB','GB','TB','PB','EB','ZB','YB'];
    var u = -1;
    do {
        bytes /= thresh;
        ++u;
    } while(bytes >= thresh);
    return bytes.toFixed(1)+' '+units[u];
};

/**
 * Parse the weird date time format in EXIF data (TIFF format)
 *
 * @param dataTimeStr
 * @returns dateTimeObj (JS Date)
 */
function parseExifDateTime(dataTimeStr, includeOffset) {
    //first split on space to get date and time parts
    // console.log('dataTimeStr', dataTimeStr);
    //var dateTimeObj;
    var bigParts = dataTimeStr.split(' ');

    if (bigParts.length == 2) {
        var date = bigParts[0].split(':');
        //var time = bigParts[1].split(':');
        var offset = $('#timeZoneOffset').val() || '+10:00';
        //offset = (offset >= 0) ? '+' + offset : offset;
        var isoDateStr = date.join('-') + 'T' + bigParts[1];
        if (includeOffset) {
            isoDateStr += offset;
        } else {
            isoDateStr = isoDateStr.replace('T', ' ');
        }
        //alert('includeOffset = ' + includeOffset + ' - ' + isoDateStr);
    }

    return isoDateStr;
}

function parseGpsTime(time) {
    // e.g. 15,5,8.01
    var bits = [];
    $.each(time.split(','), function(i, it) {
        bits.push(('0' + parseInt(it)).slice(-2)); // zero pad
    });
    return bits.join(':');
}

function addServerImage(image, index) {
    var node = $('#uploadActionsTmpl').clone(true).removeAttr('id').removeClass('hide'); //.appendTo('#files');
    node.find('.filename').append(image.title); // add filesize -  humanFileSize(file.size)

    var link = $('<a>')
        .attr('target', '_blank')
        .prop('href', image.identifier);
    node.find('.preview').wrap(link);
    node.find('.preview').append($('<img/>').attr('src',image.identifier)).attr('style','height:100px;width:100px');
    // populate hidden input fields
    //node.find('.media').val(result.url).attr('name', 'associatedMedia['+ index + ']');
    node.find('.identifier').val(image.identifier).attr('name', 'multimedia['+ index + '].identifier');
    node.find('.title').val(image.title).attr('name', 'multimedia['+ index + '].title');
    node.find('.format').val(image.mimeType).attr('name', 'multimedia['+ index + '].format');
    node.find('.creator').val(image.creator).attr('name', 'multimedia['+ index + '].creator');
    node.find('.license').val(image.creator).attr('name', 'multimedia['+ index + '].license');

    if (false) {
        //if (result.exif && result.exif.date) {
        node.find('.created').val(result.exif.date).attr('name', 'multimedia['+ index + '].created');
    }
    
    $('#imageLicenseDiv').removeClass('hide'); // show the license options
    node.appendTo('#files');
}