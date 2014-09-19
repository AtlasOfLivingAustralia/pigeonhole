<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main"/>
		<title>Identifiy</title>
        <r:require modules="jquery, leaflet"/>
        <style type="text/css">
            #locationLatLng {
                color: #DDD;
            }

            /* Base class */
            .bs-docs-example {
                position: relative;
                margin: 15px 0;
                padding: 50px 15px 14px;
                *padding-top: 19px;
                background-color: #fff;
                border: 1px solid #ddd;
                -webkit-border-radius: 4px;
                -moz-border-radius: 4px;
                border-radius: 4px;
            }

            /* Echo out a label for the example */
            .bs-docs-example:after {
                /* content: "Example"; */
                content: attr(data-content);
                position: absolute;
                top: -1px;
                left: -1px;
                padding: 6px 12px 8px 12px;
                font-size: 18px;
                font-weight: bold;
                background-color: #f5f5f5;
                border: 1px solid #ddd;
                color: #666;
                -webkit-border-radius: 4px 0 4px 0;
                -moz-border-radius: 4px 0 4px 0;
                border-radius: 4px 0 4px 0;
            }

            /* Remove spacing between an example and it's code */
            .bs-docs-example + .prettyprint {
                margin-top: -20px;
                padding-top: 15px;
            }

            .select-mini {
                font-size: 12px;
                height: 22px;
                width: auto !important;
            }

        </style>
        <r:script>
            var map, geocoding, marker, circle, radius;

            $(document).ready(function() {

                var osm = L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
                    maxZoom: 18,
                    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                        'Imagery © <a href="http://mapbox.com">Mapbox</a>',
                    id: 'examples.map-i875mjb7'
                });

                var OpenStreetMap_Mapnik = L.tileLayer('http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
                });

                var MapQuestOpen_OSM = L.tileLayer('http://otile{s}.mqcdn.com/tiles/1.0.0/map/{z}/{x}/{y}.jpeg', {
                    attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>',
                    subdomains: '1234'
                });

                var MapQuestOpen_Aerial = L.tileLayer('http://oatile{s}.mqcdn.com/tiles/1.0.0/sat/{z}/{x}/{y}.jpg', {
                    attribution: 'Tiles Courtesy of <a href="http://www.mapquest.com/">MapQuest</a> &mdash; Portions Courtesy NASA/JPL-Caltech and U.S. Depart. of Agriculture, Farm Service Agency',
                    subdomains: '1234'
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

                var baseLayers = {
                    "Street": osm,
                    "Satellite": Esri_WorldImagery
                };

                map.addLayer(osm);

                L.control.layers(baseLayers).addTo(map);

                marker = L.marker(null, {draggable: true}).on('dragend', function() {
                    updateLocation(this.getLatLng());
                });

                radius = $('#radius').val();
                circle = L.circle(null, radius * 1000,  {color: '#df4a21'}); // #bada55

                L.Icon.Default.imagePath = "${g.createLink(uri:'/js/leaflet-0.7.3/images')}";

                map.on('locationfound', onLocationFound);

                function onLocationFound(e) {
                    // create a marker at the users "latlng" and add it to the map
                    marker.setLatLng(e.latlng).addTo(map);
                    updateLocation(e.latlng);
                }

//                geocoding = new L.Geocoding();
//                map.addControl(geocoding);

                $('#geocodeinput').on('keydown', function(e) {
                    if (e.keyCode == 13 ) {
                        e.preventDefault();
                        osmGeocodeAddress();
                    }
                });

                $('#radius').change(function() {
                    updateLocation(marker.getLatLng());
                });

            }); // end document load

            function geolocate() {
                map.locate({setView: true, maxZoom: 16});
            }

            function geocode() {
                osmGeocodeAddress();
            }

            function updateSpeciesGroups() {
                var radius = $('#radius').val();
                var latlng = $('#locationLatLng span').data('latlng');

                $.ajax({
                    url : 'http://biocache.ala.org.au/ws/explore/groups.json'
                        , dataType : 'jsonp'
                        , jsonp : 'callback'
                        , data : {
                            'lat' : latlng.lat
                            , 'lon' : latlng.lng
                            , 'radius' : radius
                        }
                })
                .done(function(data){
                    //console.log("data", data);
                    if (data.length > 0) {
                        var rows = "<table class='table table-bordered table-compact'><tr>";
                        $.each(data, function(index, value){
                            if (value.level == 1 && value.speciesCount > 0) {
                                //console.log("value", value);
                                rows += "<td>" + value.name + " <span class='badge badge-infoX'>" + value.speciesCount + "</span></td>";
                            }
                        });
                        rows += "</tr><tr>";
                        $.each(data, function(index, value){
                            if (value.level == 2 && value.speciesCount > 0) {
                                console.log("value", value);
                                rows += "<td>" + value.name + " <span class='badge badge-infoX'>" + value.speciesCount + "</span></td>";
                            }
                        });
                        rows += "</tr></table>";
                        $('#speciesGroup').html(rows);
                    }
                })
                .fail(function( jqXHR, textStatus, errorThrown ) {
                    alert("Error: " + textStatus + " - " + errorThrown);
                });
            }

            function updateLocation(latlng) {
                //alert("Marker moved to: "+this.getLatLng().toString());
                $('#locationLatLng span').html(latlng.toString());
                $('#locationLatLng span').data('latlng', latlng);
                marker.setLatLng(latlng).addTo(map);
                circle.setLatLng(latlng).setRadius($('#radius').val() * 1000).addTo(map);
                map.fitBounds(circle.getBounds());
                updateSpeciesGroups()
                //console.log("zoom", map.getZoom());
            }

            function osmGeocodeAddress() {
                var query = $('#geocodeinput').val();
                $.ajax({
                    url : 'http://nominatim.openstreetmap.org/search'
                        , dataType : 'jsonp'
                        , jsonp : 'json_callback'
                        , data : {
                            'q' : query
                            , 'format' : 'json'
                        }
                    })
                .done(function(data){
                    if (data.length>0) {
                        var res = data[0];
                        var latlng = new L.LatLng(res.lat, res.lon);
                        var bounds = new L.LatLngBounds([res.boundingbox[0], res.boundingbox[2]], [res.boundingbox[1], res.boundingbox[3]])
                        map.fitBounds(bounds);
                        updateLocation(latlng);
                        //marker = L.marker(latlng, {draggable: true}).addTo(map);
                        //marker.setLatLng(latlng).addTo(map);
                    } else {
                        alert('location was not found, try a different address or place name');
                    }
                });
            }

        </r:script>
	</head>
	<body class="nav-species">
        <h2>Help with species identification</h2>
        <div class="bs-docs-example" data-content="Location">
            <p>Specify a location for the sighting:</p>
            <div class="row">
                <div class="span4">
                    <button class="btn" onClick="geolocate()">Use my location</button>
                    <div style="margin: 10px 0;"><span class="label label-info">OR</span></div>
                    <div class="hide">Enter an address, location or coordinates</div>
                    <div class="input-append">
                        <input class="span3" id="geocodeinput" type="text" placeholder="Enter an address, location or lat/lng">
                        <button id="geocodebutton" class="btn" onclick="geocode()">Lookup</button>
                    </div>
                    <div id="locationLatLng"><span></span></div>
                </div>
                <div class="span4">
                    <div id="map" style="width: 100%; height: 250px"></div>
                    <div class="" id="mapTips">Tip: drag the marker to fine-tune your location</div>
                </div>
            </div>
        </div>

        <div class="bs-docs-example" data-content="Species group">
            <p>Narrow down the identification by first choosing a species group. Species counts are based a
                <g:select name="radius" id="radius" class="select-mini" from="${[1,2,5,10,20]}" value="${defaultRadius?:5}"/>
                km area surrounding your input location</p>
            <div id="speciesGroup">Specify a location first</div>
        </div>

        <div class="bs-docs-example" data-content="Browse species images">
            <p>Narrow down the identification by browsing species images</p>
            <div id="speciesImages">Specify a species group first</div>
        </div>
	</body>
</html>
