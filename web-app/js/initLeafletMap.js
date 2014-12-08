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

var map, geocoding, marker, circle, radius, initalBounds;

$(document).ready(function() {
    if (!GSP_VARS) {
        alert('GSP_VARS not set in page - required for map widget JS');
    }

    var osm = L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
        maxZoom: 18,
        attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
            '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
            'Imagery © <a href="http://mapbox.com">Mapbox</a>',
        id: 'examples.map-i875mjb7'
    });

    var Esri_WorldImagery = L.tileLayer('http://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
        attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
        maxZoom: 17
        });

    map = L.map('map', {
        center: [-28, 134],
        zoom: 3//,
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
        updateLocation(this.getLatLng());
    });

    L.Icon.Default.imagePath = GSP_VARS.leafletImagesDir; //"${g.createLink(uri:'/js/leaflet-0.7.3/images')}";

    map.on('locationfound', onLocationFound);

    function onLocationFound(e) {
        // create a marker at the users "latlng" and add it to the map
        marker.setLatLng(e.latlng).addTo(map);
        updateLocation(e.latlng);
    }

    $('#geocodeinput').on('keydown', function(e) {
        if (e.keyCode == 13 ) {
            e.preventDefault();
            geocodeAddress();
        }
    });

    $('#geocodebutton').click(function(e) {
        e.preventDefault();
        geocodeAddress();
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
            updateMapWithLocation(lat, lng);
        }
    });

    $('#bookmarkLocation').click(function(e) {
        e.preventDefault();
        alert('Not implemented yet');
    });

}); // end document load function

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
            map.fitBounds(bounds);
            updateLocation(latlng);
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
    map.locate({setView: true, maxZoom: 16});
}

function updateLocation(latlng) {
    //console.log("Marker moved to: "+latlng.toString());
    if (latlng) {
        $('.spinner1').removeClass('hide');
        $('#decimalLatitude').val(latlng.lat);
        $('#decimalLongitude').val(latlng.lng);
        marker.setLatLng(latlng).bindPopup('your location', { maxWidth:250 }).addTo(map);
        $('#georeferenceProtocol').val('Google maps');
        $('#bookmarkLocation').removeClass('disabled').removeAttr('disabled'); // activate button
    }
}

function updateMapWithLocation(lat, lng) {
    var latlng = new L.LatLng(lat, lng);
    marker.setLatLng(latlng).addTo(map);
    map.setView(latlng, 14);
}
