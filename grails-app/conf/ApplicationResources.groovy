modules = {
    application {
        resource url: 'js/application.js'
        resource url: 'css/app.css'
    }

    jqueryUIEffects {
        dependsOn 'jquery'
        resource url:'js/jquery-ui.min.js'
    }

    fileuploads {
        dependsOn 'jquery'
        resource url:'js/jquery.fileupload/jquery.ui.widget.js'
        resource url:'js/jquery.fileupload/load-image.all.min.js'
        resource url:'js/jquery.fileupload/jquery.iframe-transport.js'
        resource url:'js/jquery.fileupload/jquery.fileupload.js'
        resource url:'js/jquery.fileupload/jquery.fileupload-process.js'
        resource url:'js/jquery.fileupload/jquery.fileupload-image.js'
        //resource url:'js/jquery.fileupload/jquery.fileupload-jquery-ui.js'
    }

    exif {
        dependsOn 'jquery'
        resource url:'js/jquery.exif.js'
    }

    leaflet {
        defaultBundle 'leaflet'
        resource url: [dir: 'js/leaflet-0.7.3', file: 'leaflet.css']
        resource url: [dir: 'js/leaflet-0.7.3', file: 'leaflet.js']
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