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

var map, geocoding, marker, circle, radius, initalBounds, bookmarks;

$(document).ready(function() {
    if (typeof GSP_VARS == 'undefined') {
        alert('GSP_VARS not set in page - required for map widget JS');
    }

    var osm = L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
            '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
            'Imagery © <a href="http://mapbox.com">Mapbox</a>',
        id: 'nickdos.kf2g7gpb'  // TODO: we should get an ALA account for mapbox.com
    });

    // in case mapbox images start failing... fall back to plain OSM
    var osm1 = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a>'
    });
    // OR
    var OpenMapSurfer_Roads = L.tileLayer('http://openmapsurfer.uni-hd.de/tiles/roads/x={x}&y={y}&z={z}', {
        minZoom: 0,
        maxZoom: 20,
        attribution: 'Imagery from <a href="http://giscience.uni-hd.de/">GIScience Research Group @ University of Heidelberg</a> &mdash; Map data &copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    });

    var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        maxZoom: 17
        });

    map = L.map('map', {
        center: [-28, 134],
        zoom: 3,
        scrollWheelZoom: false,
        worldCopyJump: true
        //layers: [osm, MapQuestOpen_Aerial]
        });

    initalBounds = map.getBounds().toBBoxString(); // save for geocoding lookups

    var baseLayers = {
        "Street": osm,
        "Satellite": Esri_WorldImagery
        };

    map.addLayer(osm);

    L.control.layers(baseLayers).addTo(map);

    marker = L.marker(null, {draggable: true}).on('dragend', function() {
        updateLocation(this.getLatLng().wrap(), true);
        console.log('position', map.latLngToLayerPoint(marker.getLatLng()));
    });

    radius = $('#coordinateUncertaintyInMeters').val();
    circle = L.circle(null, radius,  {color: '#df4a21'});

    L.Icon.Default.imagePath = GSP_VARS.leafletImagesDir; //"${g.createLink(uri:'/js/leaflet-0.7.3/images')}";

    var popup1 = L.popup().setContent('<p>Hello world!<br />This is a nice popup.</p>');

    map.on('locationfound', function(e) {
        // create a marker at the users "latlng" and add it to the map
        marker.setLatLng(e.latlng).addTo(map);
        updateLocation(e.latlng);
    }).on('locationerror', function(e){
        //console.log(e);
        alert("Location could not be determined. Try entering an address instead.");
    }).on('contextmenu',function(e){
        //alert('right click');
        popup1.openOn(map);
    });; // triggered from map.locate()


    $('#geocodeinput').on('keydown', function(e) {
        if (e.keyCode == 13 ) {
            e.preventDefault();
            geocodeAddress($(this).val());
        }
    });

    $('#geocodebutton').click(function(e) {
        e.preventDefault();
        geocodeAddress($('#geocodeinput').val());
    });

    $('#useMyLocation').click(function(e) {
        e.preventDefault();
        geolocate();
    });

    // detect change event on #decimalLongitude - update map
    $('#decimalLongitude').change(function(e) {
        var lat = $('#decimalLatitude').val();
        var lng = $('#decimalLongitude').val();

        if (lat && lng) {
            //updateMapWithLocation(lat, lng);
            updateLocation(new L.LatLng(lat, lng));
        }
    });

    $('#coordinateUncertaintyInMeters').change(function() {
        updateLocation(marker.getLatLng());
    })

    loadBookmarks();

    // Save current location
    $('#bookmarkLocation').click(function(e) {
        e.preventDefault();
        var bookmark = {
            locality: $('#locality').val(),
            userId: GSP_VARS.user.userId,
            decimalLatitude: Number($('#decimalLatitude').val()),
            decimalLongitude: Number($('#decimalLongitude').val())
        };

        $.ajax({
            url: GSP_VARS.saveBookmarksUrl,
            dataType: 'json',
            type: 'POST',
            data:  JSON.stringify(bookmark),
            contentType: 'application/json; charset=utf-8'
        }).done(function (data) {
            if (data.error) {
                alert("Location could not be saved - " + data.error, 'Error');
            } else {
                // reload bookmarks
                alert("Location was saved");
                loadBookmarks();
                //$('#bookmarkedLocations option').eq(0).after('<option value="' + bookmark.decimalLatitude + ',' + bookmark.decimalLongitude + '">' + bookmark.locality + '</option>');
            }
        }).fail(function( jqXHR, textStatus, errorThrown ) {
            alert("Error: " + textStatus + " - " + errorThrown);
        });
    });

    // Trigger loading of bookmark on select change
    $('#bookmarkedLocations').change(function(e) {
        e.preventDefault();
        var location;
        var id = $(this).find("option:selected").val();

        if (id && id != 'error') {
            $.each(bookmarks, function(i, el) {
                if (id == el.locationId) {
                    location = el;
                }
            });

            if (location) {
                var latlng =  new L.LatLng(location.decimalLatitude, location.decimalLongitude);
                updateLocation(latlng);
                //geocodeAddress(location.locality);
            } else {
                alert("Error: bookmark could not be loaded.");
            }
        } else if (id == 'error') {
            loadBookmarks();
        }
    });

    // draggable marker icon handler
    $(".drag").udraggable({
        containment: 'parent',
        stop: function(evt, el) {
            console.log("transformMarker", el);
            var x = el.offset.left + 12;
            var y = el.offset.top + 40;
            marker.setLatLng(map.containerPointToLatLng([x, y])).addTo(map);
            updateLocation(marker.getLatLng(), true);
            $(this).hide();
        }
    });

    // handler for zoom in button on Marler popup
    $('#location').on('click', '#zoomMarker', function(e) {
        e.preventDefault();
        map.setView(marker.getLatLng(), 16);
    });

}); // end document load function

function loadBookmarks() {
    $.ajax({
        url: GSP_VARS.bookmarksUrl,
        dataType: 'json',
    }).done(function (data) {
        if (data.error) {
            alert("Bookmark could not be loaded - " + data.error, 'Error');
        } else {
            // reload bookmarks
            bookmarks = data; // cache json
            // inject values into select widget
            $('#bookmarkedLocations option[value != ""]').remove(); // clear list if already loaded
            $.each(data, function(i, el) {
                $('#bookmarkedLocations').append('<option value="' + el.locationId + '">' + el.locality + '</option>');
            });
        }
    }).fail(function( jqXHR, textStatus, errorThrown ) {
        //alert("Error: " + textStatus + " - " + errorThrown);
        $('#bookmarkedLocations').append('<option value="error">Error: bookmarks could not be loaded at this time. Select to retry.</option>');
    });
}

function geocodeAddress(query) {
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
            updateLocation(latlng);
            map.fitBounds(bounds);
            marker.setPopupContent(res.formatted + " - " + latlng.toString());
            //marker = L.marker(latlng, {draggable: true}).addTo(map);
            //marker.setLatLng(latlng).addTo(map);
        } else {
            alert('location was not found, try a different address or place name');
        }
    })
    .fail(function( jqXHR, textStatus, errorThrown ) {
        alert("Error: " + textStatus + " - " + errorThrown);
    })
    .always(function() {  $('.spinner').hide(); });
}

function geolocate() {
    // this triggers a 'locationfound' event, which is registered further up in code.
    $('.spinner0').show();
    map.locate({setView: true, maxZoom: 16}).on('locationfound', function(e){
        $('.spinner0').hide();
    }).on('locationerror', function(e){
        $('.spinner0').hide();
        alert("Location failed: " + e.message);
    });
}

function updateLocation(latlng, keepView) {
    //console.log("Marker moved to: "+latlng.toString());
    if (latlng) {
        $('.spinner1').removeClass('hide');
        $('.drag').hide();
        $('#decimalLatitude').val(latlng.lat);
        $('#decimalLongitude').val(latlng.lng);
        marker.setLatLng(latlng).bindPopup('<div>Sighting location</div><button class="btn btn-small" id="zoomMarker">Zoom in</button>', { maxWidth:250 }).addTo(map);
        circle.setLatLng(latlng).setRadius($('#coordinateUncertaintyInMeters').val()).addTo(map);
        if (!keepView) {
            map.setView(latlng, 16);
        }
        $('#georeferenceProtocol').val('Google maps');
        $('#bookmarkLocation').removeClass('disabled').removeAttr('disabled'); // activate button
        reverseGeocode(latlng.lat, latlng.lng);
        if (latlng.lat > 0 || latlng.lng < 100) {
            alert("Coordinates are not in the Australasia region. Are you sure this location is correct?");
        }
    }
}

function reverseGeocode(lat, lng) {
    // http://nominatim.openstreetmap.org/reverse?format=json&lat=-30.1484782&lon=153.1961178&zoom=18&addressdetails=1&accept-language=en&json_callback=foo123
    //console.log("lat lng", lat, lng);
    if (lat && lng) {
        $('#locality').val('');
        var url = "http://nominatim.openstreetmap.org/reverse?format=json&lat="+lat+
            "&lon="+lng+"&zoom=18&addressdetails=1&accept-language=en&json_callback=?";
        $.getJSON(url).done(function(data){
            if (data && !data.error) {
                $('#locality').val(data.display_name);
            }
        }).fail(function( jqXHR, textStatus, errorThrown ) {
            alert("Error: " + textStatus + " - " + errorThrown);
        }).always(function() {  //
            // $('.spinner').hide();
        });
    }

}