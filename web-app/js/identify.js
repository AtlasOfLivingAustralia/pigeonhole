/*
 * Copyright (C) 2015 Atlas of Living Australia
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

/**
 * Created by dos009 on 18/05/15.
 */

var groupSelected, subgroupSelected;
//var lat = GSP_VARS.lat;
//var lng = GSP_VARS.lng;

var biocacheBaseUrl = GSP_VARS.biocacheBaseUrl;

$(document).ready(function() {

    updateSubGroups(null, GSP_VARS.lat, GSP_VARS.lng);

    $('#radius').change(function() {
        //updateLocation();
        updateSubGroups(null, GSP_VARS.lat, GSP_VARS.lng);
    });

    $('#speciesGroup').on('click', '.groupBtn', function(e) {
        $('#speciesGroup .btn').removeClass('btn-primary');
        $(this).addClass('btn-primary');
        var selected = $(this).data('group');

        $('#speciesSubGroup .sub-groups').addClass('hide'); // hide all subgroups
        $('#subgroup_' + selected).removeClass('hide'); // expose requested subgroup
        groupSelected = selected;
        //updateSubGroups($(this).data('group'));
        loadSpeciesGroupImages('species_group:' + unescape(selected), null, $(this).find('.badge').text());
    });

    $('#speciesSubGroup').on('click', '.subGroupBtn', function(e) {
        $('#speciesSubGroup .btn').removeClass('btn-primary');
        $(this).addClass('btn-primary');
        var selected = $(this).data('group');
        subgroupSelected = selected;
        loadSpeciesGroupImages('species_subgroup:' + unescape(selected), null, $(this).find('.badge').text());
    });

    // mouse over affect on thumbnail images
    $('#speciesImagesDiv').on('hover', '.imgCon', function() {
        $(this).find('.brief, .detail').toggleClass('hide');
    });

    $('#speciesImagesDiv').on('inview', '#end', function(event, isInView, visiblePartX, visiblePartY) {
        //console.log("inview", isInView, visiblePartX, visiblePartY);
        if (isInView) {
            //console.log("images bottom in view");
            var start = $('#speciesImagesDiv').data('start');
            var speciesGroup = $('#speciesImagesDiv').data('species_group');
            loadSpeciesGroupImages(speciesGroup, start)
        }
    });

    $('#toggleNoImages').on('change', function(e) {
        $('.imgCon.noImage').toggleClass('hide');
    });

    $('#speciesImagesDiv').on('click', '.imgCon a', function() {
        var lsid = $(this).data('lsid');
        //var name = $(this).find('.brief').html(); // TODO: store info in object and store object in 'data' attribute
        var displayname = $(this).data('displayname');
        loadSpeciesPopup(lsid, displayname);
        return false;
    });

    var prevImgId, prevWidth;
    $('#singleSpeciesImages').on('click', '.imgCon a', function() {
        var img = $(this).find('img');
        var imgId = $(img).attr('id');
        //var thisImgId =  $(img).attr('src');
        //var isZoomed = $(img).hasClass('zoomed');
        //$('#singleSpeciesImages img').removeClass('zoomed');
        //console.log("img clicked!", imgId, prevImgId, prevWidth);

        function shrink(theImg) {
            $(theImg).animate({
                width: prevWidth,
                height: "90"
            },'fast', function() {
                //console.log("setting preImg to null",prevImgId);
                $(theImg).css('maxWidth','150px').css('cursor','zoom-in');
                prevImgId = null;
            });
        }

        function enlarge(theImg) {
            $(theImg).css('maxWidth','none').css('cursor','zoom-out');
            prevWidth = $(theImg).width();
            var imageCopy = new Image();
            imageCopy.src = theImg.attr("src");

            $(theImg).animate({
                width: imageCopy.width,
                height: imageCopy.height
            },'fast', function() {
                console.log("setting preImg to img",prevImgId);
                prevImgId = imgId;
            });
        }

        if (prevImgId && prevImgId != imgId) {
            // shrink the prev img and enlarge this img
            shrink($('#singleSpeciesImages img#' + prevImgId));
            enlarge(img);
            //prevImg = img;
        } else if (prevImgId && prevImgId == imgId) {
            // same img clicked so shrink img
            shrink(img, null);
            //prevImg = null;
        } else {
            // no prev img enlarged
            enlarge(img);
            //prevImg = img;
        }
    });

    /**
     * Custom button listener for fragment/submit sighting page
     */
    $('#selectedSpeciesBtn').click(function() {
        //var returnUrl = $.url().param("returnUrl");
        var lsid = $('#imgModal').data('lsid');
        $('#guid').val(lsid).change(); // will trigger lookup in BIE

        //var queryStr = "";
        if (groupSelected || subgroupSelected) {

            if (groupSelected) {
                addTagLabel(groupSelected);
            }
            if (subgroupSelected) {
                addTagLabel(unescape(subgroupSelected));
            }
            //queryStr = "?" + paramsList.join("&");
        }
        $('.modal').modal('hide'); // hide all
        $('#identifyHelpModal').modal('hide');
        //window.location = returnUrl + "/" + lsid + queryStr;
    });


}); // end document load

function imgError(image){
    image.onerror = "";
    image.src = GSP_VARS.contextPath + "/images/noImage.jpg";

    //console.log("img", $(image).parents('.imgCon').html());
    //$(image).parents('.imgCon').addClass('hide');// hides species without images
    var hide = ($('#toggleNoImages').is(':checked')) ? 'hide' : '';
    $(image).parents('.imgCon').addClass('noImage ' + hide);// hides species without images
    return true;
}



function geocode() {
    geocodeAddress();
}

function updateSubGroups(group, lat, lng) {
    var radius = $('#radius').val();
    //var latlng = $('#locationLatLng span').data('latlng');

    $.ajax({
        url : biocacheBaseUrl + '/explore/hierarchy/groups.json'
        , dataType : 'jsonp'
        , jsonp : 'callback'
        , data : {
            'lat' : lat
            , 'lon' : lng
            , 'radius' : radius
            , 'fq' : 'rank_id:[7000 TO *]' // TODO - check this is not being ignored by biocache-service
            , 'speciesGroup': group
        }
    })
    .done(function(data){
        var group = "<div id='speciesGroup1' class=''>";
        $('#speciesSubGroup').html('');

        $.each(data, function(index, value){
            // console.log(index, value);
            var btn = ''; //(index == 0) ? 'btn-primary' : '';
            group += "<div class='btn groupBtn " +  btn + "' data-group='" + escape(value.name) + "'>" + value.name + " <span class='counts'>[" + value.speciesCount + "]</span></div>";

            if (value.childGroups.length > 0) {
                var hide = 'hide'; //(index == 0) ? '' : 'hide';
                var subGroup = "<div id='subgroup_" + value.name + "' class='sub-groups " + hide + "'>";
                $.each(value.childGroups, function(i, el){
                    subGroup += "<div class='btn subGroupBtn' data-group='" + escape(el.name) + "'>" + el.name + " <span class='counts'>[" + el.speciesCount + "]</span></div>";
                });
                $('#speciesSubGroup').append(subGroup);
            }
        });

        $('#speciesGroup').html(group);
        $('#species_group p.hide').removeClass('hide');
    })
    .always(function() {
        $('.spinner1').addClass('hide');
    })
    .fail(function( jqXHR, textStatus, errorThrown ) {
        alert("Error: " + textStatus + " - " + errorThrown);
    });
}

function loadSpeciesGroupImages(speciesGroup, start) {
    if (!start) {
        start = 0;
        $('#speciesImagesDiv').empty();
    } else {
        $( "#end" ).remove(); // remove the trigger element for the inview loading of more images
    }

    var pageSize = 30;
    var radius = $('#radius').val();
    var latlng = $('#locationLatLng span').data('latlng');
    var lat, lng;

    if (latlng) {
        lat = latlng.lat;
        lng = latlng.lng;
    } else {
        lat = GSP_VARS.lat;
        lng = GSP_VARS.lng;
    }

    $('.spinner2').removeClass('hide');
    jQuery.ajaxSettings.traditional = true; // so multiple params with same key are formatted right
    //var url = "http://biocache.ala.org.au/ws/occurrences/search?q=species_subgroup:Parrots&fq=geospatial_kosher%3Atrue&fq=multimedia:Image&facets=multimedia&lat=-35.2792511&lon=149.1113017&radius=5"
    $.ajax({
        url : biocacheBaseUrl + '/occurrences/search.json',
        dataType : 'jsonp',
        jsonp : 'callback',
        data : {
            'q' : '*:*',
            'fq': [ speciesGroup,
                'rank_id:[7000 TO *]' // remove higher taxa
                //'geospatial_kosher:true'],
            ],
            //'fq': speciesGroup,
            'facets': 'common_name_and_lsid',
            'flimit': pageSize,
            'foffset': start,
            'start': 0,
            'pageSize': 0,
            'lat' : lat,
            'lon' : lng,
            'radius' : radius
        }
    })
        .done(function(data){
            if (data.facetResults && data.facetResults.length > 0 && data.facetResults[0].fieldResult.length > 0) {
                //console.log(speciesGroup + ': species count = ' + data.facetResults[0].fieldResult.length);
                var images = "<span id='imagesGrid'>";
                var newTotal = Number(start);
                $.each(data.facetResults[0].fieldResult, function(i, el){
                    //if (i >= 30) return false;
                    newTotal++;
                    var parts = el.label.split("|");
                    var nameObj = {
                        sciName: parts[1],
                        commonName: parts[0],
                        lsid: parts[2],
                        shortName: (parts[0]) ? parts[0] : "<i>" + parts[1] + "</i>",
                        fullName1: (parts[0]) ? parts[0] + " &mdash; " + "<i>" + parts[1] + "</i>" : "<i>" + parts[1] + "</i>",
                        fullName2: (parts[0]) ? parts[0] + "<br>" + "<i>" + parts[1] + "</i>" : "<i>" + parts[1] + "</i>"
                    };
                    var displayName = $('<div/>').text(nameObj.fullName1).html(); // use jQuery to escape text
                    var imgUrl = "http://bie.ala.org.au/ws/species/image/small/" + nameObj.lsid; // http://bie.ala.org.au/ws/species/image/thumbnail/urn:lsid:biodiversity.org.au:afd.taxon:aa745ff0-c776-4d0e-851d-369ba0e6f537
                    images += "<div class='imgCon'><a class='cbLink thumbImage tooltips' rel='thumbs' href='http://bie.ala.org.au/species/" +
                    nameObj.lsid + "' target='species' data-lsid='" + nameObj.lsid + "' data-displayname='" + displayName + "'><img src='" + imgUrl +
                    "' alt='species thumbnail' onerror='imgError(this);'/><div class='meta brief'>" +
                    nameObj.shortName + "</div><div class='meta detail hide'>" +
                    nameObj.fullName2 + "<br>Records: " + el.count + "</div></a></div>";
                });
                images += "</span>";
                images += "<div id='end'>&nbsp;</div>";
                $('#speciesImagesDiv').append(images);
                $('#speciesImagesDiv').data('start', start + pageSize);
                $('#speciesImagesDiv').data('species_group', speciesGroup);
                //$('#speciesImagesDiv').data('total', total);
            } else if (!start) {
                $('#speciesImagesDiv').append("No species found.");
            }
        })
        .always(function() {
            $('.spinner2').addClass('hide');
        })
        .fail(function( jqXHR, textStatus, errorThrown ) {
            // alert("Error: " + textStatus + " - " + errorThrown);
            $('#speciesImagesDiv').append("Error: " + textStatus + " - " + errorThrown);
        });
}

function clearGroupsAndImages() {
    $('#speciesGroup').empty();
    $('#speciesSubGroup').empty();
    $('#speciesImagesDiv').empty();
    subgroupSelected = null;
    groupSelected = null;
}

function geocodeAddress() {
    var query = $('#geocodeinput').val();
    $.ajax({
        // https://api.opencagedata.com/geocode/v1/json?q=Canberra,+ACT&key=577ca677f86a3a4589b17814ec399112
        url : 'https://api.opencagedata.com/geocode/v1/json',
        dataType : 'jsonp',
        jsonp : 'callback',
        data : {
            'q' : query,
            'key': '577ca677f86a3a4589b17814ec399112', // key for username 'nickdos' with pw 'ac..on',
            'bounds': initalBounds // restricts search to initla map view
        }
    })
        .done(function(data){
            //console.log("geonames", data);
            if (data.results.length > 0) {
                var res = data.results[0];
                var latlng = new L.LatLng(res.geometry.lat, res.geometry.lng);
                var bounds = new L.LatLngBounds([res.bounds.southwest.lat, res.bounds.southwest.lng], [res.bounds.northeast.lat, res.bounds.northeast.lng]);
                map1.fitBounds(bounds);
                updateLocation(latlng);
                marker.setPopupContent(res.formatted + " - " + latlng.toString());
                //marker = L.marker(latlng, {draggable: true}).addTo(map1);
                //marker.setLatLng(latlng).addTo(map1);
            } else {
                alert('location was not found, try a different address or place name');
            }
        })
        .fail(function( jqXHR, textStatus, errorThrown ) {
            alert("Error: " + textStatus + " - " + errorThrown);
        })
        .always(function() {  $('.spinner').hide(); });
}

function loadSpeciesPopup(lsid, name) {
    $('#imgModalLabel, #speciesDetails, #singleSpeciesImages').empty(); // clear any old values
    $('#imgModalLabel').html(name);
    $('<a class="btn btn-small bieBtn" href="http://bie.ala.org.au/species/' + lsid +
    '" target="bie"><i class="icon-info-sign"></i> species page</a>').appendTo($('#imgModalLabel'));
    $('#spinner3').removeClass('hide');
    var start = 0, pageSize = 20;
    $.ajax({
        url : biocacheBaseUrl + '/occurrences/search.json',
        dataType : 'jsonp',
        jsonp : 'callback',
        data : {
            'q' : 'lsid:' + lsid,
            'fq': [
                'multimedia:Image' // images only
                //'geospatial_kosher:true'],
            ],
            'facet': 'off',
            //'flimit': pageSize,
            //'foffset': ,
            'start': start,
            'pageSize': pageSize
        }
    })
    .done(function(data){
        if (data.occurrences && data.occurrences.length > 0) {
            $.each(data.occurrences, function(i, occ){
                //clone imgCon div and populate with data
                var $clone = $('#imgConClone').clone();
                $clone.attr("id",""); // remove the ID
                $clone.removeClass("hide");
                $clone.find("img").attr('src', occ.smallImageUrl);
                $clone.find("img").attr('id', occ.image);
                $clone.find(".meta").addClass("hide");
                //console.log('clone', $clone);
                $('#singleSpeciesImages').append($clone);
            });
            $('#imgModal').data('lsid', lsid);
        }
    })
    .fail(function( jqXHR, textStatus, errorThrown ) {
        alert("Error: " + textStatus + " - " + errorThrown);
    })
    .always(function() {  $('#spinner3').addClass('hide'); });

    $('#imgModal').modal(); // trigger modal popup
}
