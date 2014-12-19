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

modules = {
    application {
        resource url: 'js/application.js'
        resource url: 'css/app.css'
    }

    jqueryMigrate {
        dependsOn 'jquery'
        resource url:'http://code.jquery.com/jquery-migrate-1.2.1.min.js'
    }

    jqueryUIEffects {
        dependsOn 'jqueryMigrate'
        resource url:'js/jquery-ui.min.js'
    }

    alaAutocomplete {
        dependsOn 'jqueryMigrate, bootstrap'
        resource url:'css/alaAutocomplete.css'
        resource url:'js/typeahead.bundle.js'
        //resource url:'http://twitter.github.io/typeahead.js/css/examples.css'
        resource url:'js/alaAutocomplete.js'
    }

    submitSighting {
        dependsOn 'jqueryMigrate'
        resource url:'/css/submit.css'
        resource url:'/js/submit.js'
    }

    fileuploads {
        dependsOn 'jqueryMigrate'
        resource url:'js/jquery.fileupload/jquery.ui.widget.js'
        resource url:'js/jquery.fileupload/load-image.all.min.js'
        resource url:'js/jquery.fileupload/jquery.iframe-transport.js'
        resource url:'js/jquery.fileupload/jquery.fileupload.js'
        resource url:'js/jquery.fileupload/jquery.fileupload-process.js'
        resource url:'js/jquery.fileupload/jquery.fileupload-image.js'
        //resource url:'js/jquery.fileupload/jquery.fileupload-jquery-ui.js'
    }

    imageBrowser {
        dependsOn 'jqueryMigrate'
        resource url:'js/imageBrowser.js'
    }

    qtip {
        dependsOn 'jquery'
        resource url:[dir:'css', file:'jquery.qtip.min.css']
        resource url:[dir:'js', file:'jquery.qtip.min.js']
    }

    moment {
        resource url:'js/moment.min.js'
        resource url:'js/moment-duration-format.js'
    }

    datepicker {
        // http://www.eyecon.ro/bootstrap-datepicker/
        dependsOn 'jqueryMigrate'
        resource url:'js/datepicker/css/datepicker.css'
        resource url:'js/datepicker/js/bootstrap-datepicker.js'
    }

    exif {
        dependsOn 'jqueryMigrate'
        resource url:'js/jquery.exif.js'
    }

    leaflet {
        defaultBundle 'leaflet'
        resource url: [dir: 'js/leaflet-0.7.3', file: 'leaflet.css']
        resource url: [dir: 'js/leaflet-0.7.3', file: 'leaflet.js']
    }

    sightingMap {
        dependsOn 'leaflet'
        resource url: '/js/initLeafletMap.js'
    }

    leafletLocate {
        dependsOn 'leaflet'
        resource url: 'js/leaflet-plugins/leaflet-locatecontrol-gh-pages/src/L.Control.Locate.js'
        //resource url:'http://api.tiles.mapbox.com/mapbox.js/plugins/leaflet-locatecontrol/v0.24.0/L.Control.Locate.js'
        resource url: [dir: 'js/leaflet-plugins/leaflet-locatecontrol-gh-pages/src', file: 'L.Control.Locate.css']
        //resource url:'http://api.tiles.mapbox.com/mapbox.js/plugins/leaflet-locatecontrol/v0.24.0/L.Control.Locate.css'
        resource url: [dir: 'js/leaflet-plugins/leaflet-locatecontrol-gh-pages/src', file: 'L.Control.Locate.ie.css'], wrapper: { s -> "<!--[if lt IE 9]>$s<![endif]-->" }
    }

    leafletGeoSearch {
        dependsOn 'leaflet'
        resource url: [dir: 'js/leaflet-plugins/L.GeoSearch/src/js', file: 'l.control.geosearch.js']
        resource url: [dir: 'js/leaflet-plugins/L.GeoSearch/src/js', file: 'l.geosearch.provider.google.js']
        resource url: [dir: 'js/leaflet-plugins/L.GeoSearch/src/js', file: 'l.geosearch.provider.openstreetmap.js']
        resource url: [dir: 'js/leaflet-plugins/L.GeoSearch/src/css', file: 'l.geosearch.css']
    }

    leafletGeocoding {
        dependsOn 'leaflet'
        resource url: 'js/leaflet-plugins/leaflet.geocoding/leaflet.geocoding.js'
    }

    inview {
        dependsOn 'jquery'
        resource url: 'js/jquery.inview.js'
    }
}