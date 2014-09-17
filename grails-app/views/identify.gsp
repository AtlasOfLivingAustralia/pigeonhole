<!DOCTYPE html>
<html>
	<head>
		<meta name="layout" content="main"/>
		<title>Identifiy</title>
        <r:require modules="jquery, leaflet, leafletGeoSearch, leafletLocate"/>
        <r:script>
            $(document).ready(function() {
                var map = L.map('map').setView([-28, 134], 4);
                L.Icon.Default.imagePath = "${g.createLink(uri:'/js/leaflet-0.7.3/images')}";

                L.tileLayer('https://{s}.tiles.mapbox.com/v3/{id}/{z}/{x}/{y}.png', {
                    maxZoom: 18,
                    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
                            '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
                            'Imagery © <a href="http://mapbox.com">Mapbox</a>',
                    id: 'examples.map-i86knfo3'
                }).addTo(map);

                L.control.locate({position:'topright', icon:'location-icon', markerClass: L.marker}).addTo(map);

                new L.Control.GeoSearch({
                    provider: new L.GeoSearch.Provider.OpenStreetMap(),
                    position: 'topright',
                    showMarker: true
                }).addTo(map);

                map.on('geosearch_showlocation', function (result) {
                    //console.log('zoom to: ' + result.Location.Label);
                    thisLatLon = result.Location.X + " " + result.Location.Y;
                    alert('your lat/lng is: ' + thisLatLon);
                });

            });

        </r:script>
	</head>
	<body class="nav-species">
        <h2>Help with species identification</h2>
        <div class="row-fluid">
            <div class="span6">
                <div id="map" style="width: 100%; height: 500px"></div>
            </div>
            <div class="span6">
                <div>Some controls go here</div>
            </div>
        </div>
	</body>
</html>
