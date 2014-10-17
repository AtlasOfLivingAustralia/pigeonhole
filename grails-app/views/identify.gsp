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
                width: auto !important;
                height: 24px;
                font-size: 12px;
                line-height: 20px;
                margin-bottom: 2px;
            }

            #speciesGroup {
                /*width: 18%;*/
                /*float: left;*/
                margin-bottom: 10px;
            }

            #speciesSubGroup {
                /*width: 80%;*/
                /*float: left;*/
                /*padding-left: 15px;*/
                /*margin-top: 20px;*/
            }

            #speciesSubGroup .btn-group {
                margin-left: 0 !important;
                margin-top: 10px;
            }

            .sub-groups {
                /*display: inline-block;*/
                /*margin-top: 10px;*/
            }

            .sub-groups .btn {
                margin-bottom: 4px;
                margin-right: 4px;
            }

            /* Gallery styling */
            .imgCon {
                display: inline-block;
                /* margin-right: 8px; */
                text-align: center;
                line-height: 1.3em;
                background-color: #DDD;
                color: #DDD;
                font-size: 12px;
                /*text-shadow: 2px 2px 6px rgba(255, 255, 255, 1);*/
                /* padding: 5px; */
                /* margin-bottom: 8px; */
                margin: 2px 4px 2px 0;
                position: relative;
            }
            .imgCon img {
                height: 170px;
                min-width: 150px;
            }
            .imgCon .meta {
                opacity: 0.8;
                position: absolute;
                bottom: 0;
                left: 0;
                right: 0;
                overflow: hidden;
                text-align: left;
                padding: 4px 5px 2px 5px;
            }
            .imgCon .brief {
                color: black;
                background-color: white;
            }
            .imgCon .detail {
                color: white;
                background-color: black;
                opacity: 0.7;
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

                $('#geocodeinput').on('keydown', function(e) {
                    if (e.keyCode == 13 ) {
                        e.preventDefault();
                        osmGeocodeAddress();
                    }
                });

                $('#radius').change(function() {
                    updateLocation(marker.getLatLng());
                });

                $('#speciesGroup').on('click', '.groupBtn', function(e) {
                    $('#speciesGroup .btn').removeClass('btn-primary');
                    $(this).addClass('btn-primary');

                    $('#speciesSubGroup .sub-groups').addClass('hide'); // hide all subgroups
                    $('#subgroup_' + $(this).data('group')).removeClass('hide'); // expose requested subgroup
                    //updateSubGroups($(this).data('group'));
                    loadSpeciesGroupImages('species_group:' + unescape($(this).data('group')));
                });

                $('#speciesSubGroup').on('click', '.subGroupBtn', function(e) {
                    $('#speciesSubGroup .btn').removeClass('btn-primary');
                    $(this).addClass('btn-primary');
                    loadSpeciesGroupImages('species_subgroup:' + unescape($(this).data('group')));
                });

                %{--$("img").error(function () {--}%
                     %{--$(this).unbind("error").attr("src", "${createLink(uri: "/images/noImage.jpg")}");--}%
                %{--});--}%

                // mouse over affect on thumbnail images
                $('#speciesImages').on('hover', '.imgCon', function() {
                    $(this).find('.brief, .detail').toggleClass('hide');
                });

        }); // end document load

        function imgError(image){
            image.onerror = "";
            image.src = "${createLink(uri: "/images/noImage.jpg")}";
                return true;
            }

            function geolocate() {
                map.locate({setView: true, maxZoom: 16});
            }

            function geocode() {
                osmGeocodeAddress();
            }

            function updateSubGroups(group) {
                var radius = $('#radius').val();
                var latlng = $('#locationLatLng span').data('latlng');

                $.ajax({
                    url : 'http://localhost:8080/biocache-service/explore/hierarchy/groups.json'
                        , dataType : 'jsonp'
                        , jsonp : 'callback'
                        , data : {
                            'lat' : latlng.lat
                            , 'lon' : latlng.lng
                            , 'radius' : radius
                            , 'speciesGroup': group
                        }
                })
                .done(function(data){
                    var group = "<div id='speciesGroup1' class='btn-group '>";
                    $('#speciesSubGroup').html('');

                    $.each(data, function(index, value){
                        console.log(index, value);
                        var btn = (index == 0) ? 'btn-primary' : '';
                        group += "<div class='btn groupBtn " +  btn + "' data-group='" + escape(value.name) + "'>" + value.name + " <span class='badge badge-infoX'>" + value.speciesCount + "</span></div>";

                        if (value.childGroups.length > 0) {
                            var hide = (index == 0) ? '' : 'hide';
                            var subGroup = "<div id='subgroup_" + value.name + "' class='sub-groups " + hide + "'>";
                            $.each(value.childGroups, function(i, el){
                                subGroup += "<div class='btn subGroupBtn' data-group='" + escape(el.name) + "'>" + el.name + " <span class='badge badge-infoX'>" + el.speciesCount + "</span></div>";
                            });
                            $('#speciesSubGroup').append(subGroup);
                        }
                    });

                    $('#speciesGroup').html(group);
                    $('#speciesImages').empty();
                })
                .fail(function( jqXHR, textStatus, errorThrown ) {
                    alert("Error: " + textStatus + " - " + errorThrown);
                });
            }

            function loadSpeciesGroupImages(speciesGroup) {
                var radius = $('#radius').val();
                var latlng = $('#locationLatLng span').data('latlng');
                jQuery.ajaxSettings.traditional = true; // so multiple params with same key are formatted right
                //var url = "http://biocache.ala.org.au/ws/occurrences/search?q=species_subgroup:Parrots&fq=geospatial_kosher%3Atrue&fq=multimedia:Image&facets=multimedia&lat=-35.2792511&lon=149.1113017&radius=5"
                $.ajax({
                    url : 'http://biocache.ala.org.au/ws/occurrences/search.json',
                        dataType : 'jsonp',
                        jsonp : 'callback',
                        data : {
                            'q' : '*:*',
                            'fq': [ speciesGroup
                                   //'geospatial_kosher:true'],
                                   ],
                            //'fq': speciesGroup,
                            'facets': 'common_name_and_lsid',
                            'flimit': 999,
                            'pageSize': 0,
                            'lat' : latlng.lat,
                            'lon' : latlng.lng,
                            'radius' : radius
                        }
                })
                .done(function(data){
                    if (data.facetResults && data.facetResults.length > 0 && data.facetResults[0].fieldResult.length > 0) {
                        //console.log(speciesGroup + ': species count = ' + data.facetResults[0].fieldResult.length);
                        var images = "<div id='imagesGrid'>";
                        $.each(data.facetResults[0].fieldResult, function(i, el){
                            if (i >= 30) return false;
                            var parts = el.label.split("|");
                            var lsid = parts[2];
                            var displayName = (parts[0]) ? parts[0] : "<i>" + parts[1] + "</i>";
                            var imgUrl = "http://bie.ala.org.au/ws/species/image/small/" + lsid; // http://bie.ala.org.au/ws/species/image/thumbnail/urn:lsid:biodiversity.org.au:afd.taxon:aa745ff0-c776-4d0e-851d-369ba0e6f537
                            images += "<div class='imgCon'><a class='cbLink thumbImage tooltips' rel='thumbs' href='http://bie.ala.org.au/species/" +
                                    lsid + "' target='species'><img src='" + imgUrl +
                                    "' alt='species thumbnail' onerror='imgError(this);'/><div class='meta brief'>" +
                                    displayName + "</div><div class='meta detail hide'><i>" +
                                    parts[1] + "</i><br>" + parts[0] + "<br>Records: " + el.count + "</div></a></div>";
                        });
                        images += "</div>";
                        $('#speciesImages').html(images);
                    } else {
                        $('#speciesImages').html("No species found.");
                    }
                })
                .fail(function( jqXHR, textStatus, errorThrown ) {
                    // alert("Error: " + textStatus + " - " + errorThrown);
                    $('#speciesImages').html("Error: " + textStatus + " - " + errorThrown);
                });
            }

            function updateLocation(latlng) {
                //alert("Marker moved to: "+this.getLatLng().toString());
                $('#speciesGroup span, #speciesImages span').hide();
                $('.spinner').show();
                $('#locationLatLng span').html(latlng.toString());
                $('#locationLatLng span').data('latlng', latlng);
                marker.setLatLng(latlng).addTo(map);
                circle.setLatLng(latlng).setRadius($('#radius').val() * 1000).addTo(map);
                map.fitBounds(circle.getBounds());
                //updateSpeciesGroups()
                updateSubGroups();
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
                })
                .always(function() {  $('.spinner').hide(); });
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
                    <div>Show known species in a
                    <g:select name="radius" id="radius" class="select-mini" from="${[1,2,5,10,20]}" value="${defaultRadius?:5}"/>
                    km area surrounding this location</div>
                    <div id="locationLatLng"><span></span></div>
                </div>
                <div class="span4">
                    <div id="map" style="width: 100%; height: 250px"></div>
                    <div class="" id="mapTips">Tip: drag the marker to fine-tune your location</div>
                </div>
            </div>
        </div>

        <div class="bs-docs-example" data-content="Species group">
            <p>Narrow down the identification by first choosing a species group.</p>
            <div id="speciesGroup"><span>[Specify a location first]</span><r:img uri="/images/spinner.gif" class="spinner hide"/></div>
            <p>Choose a species sub-group.</p>
            <div id="speciesSubGroup"></div>
            <div class="clearfix"></div>
        </div>

        <div class="bs-docs-example" data-content="Browse species images">
            <p>Narrow down the identification by browsing species images</p>
            <div id="speciesImages"><span>[Specify a location first]</span></div>
        </div>
	</body>
</html>
