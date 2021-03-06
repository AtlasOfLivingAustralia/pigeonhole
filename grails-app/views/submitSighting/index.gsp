%{--
  - Copyright (C) 2014 Atlas of Living Australia
  - All Rights Reserved.
  -
  - The contents of this file are subject to the Mozilla Public
  - License Version 1.1 (the "License"); you may not use this file
  - except in compliance with the License. You may obtain a copy of
  - the License at http://www.mozilla.org/MPL/
  -
  - Software distributed under the License is distributed on an "AS
  - IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
  - implied. See the License for the specific language governing
  - rights and limitations under the License.
  --}%

<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 6/11/2014
  Time: 4:35 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="grails.converters.JSON" contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="${grailsApplication.config.skin.layout}"/>
    <title>Record a sighting | ${grailsApplication.config.skin.orgNameLong}</title>
    <r:require modules="fileuploads, exif, moment, pigeonhole, bs3_datepicker, udraggable, fontawesome, purl, submitSighting, jqueryUIEffects, inview, identify, leafletGoogle"/>
    <r:script disposition="head">
        // global var to pass in GSP/Grails values into external JS files
        GSP_VARS = {
            biocacheBaseUrl: "${(grailsApplication.config.biocache.baseUrl)}",
            bieBaseUrl: "${(grailsApplication.config.bie.baseUrl)}",
            bieServiceBaseUrl: "${(grailsApplication.config.bieService.baseUrl)}",
            uploadUrl: "${createLink(uri:"/ajax/upload")}",
            bookmarksUrl: "${createLink(controller:"ajax", action:"getBookmarkLocations")}",
            saveBookmarksUrl: "${createLink(controller:"ajax", action:"saveBookmarkLocation")}",
            contextPath: "${request.contextPath}",
            //bookmarks: ${(bookmarks).encodeAsJson()?:'{}'},
            guid: "${taxon?.guid}",
            noImageUrl: "${resource(dir: 'images', file: 'noImage.jpg')}",
            speciesGroups: ${(speciesGroupsMap).encodeAsJson()?:'{}'}, // TODO move this to an ajax call (?)
            leafletImagesDir: "${g.createLink(uri:'/js/leaflet-0.7.3/images')}",
            user: ${(user).encodeAsJson()?:'{}'},
            sightingBean: ${(sighting).encodeAsJson()?:'{}'},
            validateUrl: "${createLink(controller: 'sightings', action:'validate')}",
            defaultMapLng: ${grailsApplication.config.defaultMapLng?:'134'},
            defaultMapLat: ${grailsApplication.config.defaultMapLat?:'-28'},
            defaultMapZoom: ${grailsApplication.config.defaultMapZoom?:'3'},
            geocodeRegion: '${grailsApplication.config.defaultGeocodeRegion?:'AU'}',
            expectedRegionName: '${grailsApplication.config.expectedRegionName?:'Australasia'}',
            expectedMinLat: ${grailsApplication.config.expectedMinLat?:'-90'},
            expectedMinLng: ${grailsApplication.config.expectedMinLng?:'0'},
            expectedMaxLat: ${grailsApplication.config.expectedMaxLat?:'0'},
            expectedMaxLng: ${grailsApplication.config.expectedMaxLng?:'180'}
        };

        function imgError(image){
            image.onerror = "";
            image.src = GSP_VARS.contextPath + "/images/noImage.jpg";

            //console.log("img", $(image).parents('.imgCon').html());
            //$(image).parents('.imgCon').addClass('hide');// hides species without images
            var hide = ($('#toggleNoImages').is(':checked')) ? 'hide' : '';
            $(image).parents('.imgCon').addClass('noImage ' + hide);// hides species without images
            return true;
        }


    </r:script>
</head>
<body class="nav-species record-sighting">
<g:render template="/topMenu"  model="[pageHeading: 'Record a Sighting']"/>
<div class="row">
    <div class="col-sm-12">
        <g:set var="errorsShown" value="${false}"/>
        <g:hasErrors bean="${sighting}">
            <g:set var="errorsShown" value="${true}"/>
            <div class="">
                <div class="alert alert-danger">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${raw(flash.message)}
                    <g:eachError var="err" bean="${sighting}">
                        <li><g:message code="sighting.field.${err.field}"/> - <g:fieldError bean="${sighting}"  field="${err.field}"/></li>
                    </g:eachError>
                </div>
            </div>
        </g:hasErrors>
        <g:if test="${!errorsShown && (flash.message || sighting?.error)}">
            <div class="">
                <div class="alert alert-danger">
                    <button type="button" class="close" data-dismiss="alert">&times;</button>
                    ${raw(flash.message)?:sighting?.error}
                </div>
            </div>
        </g:if>
    </div>
</div>
<div class="row">
    <div class="col-sm-12 col-md-12 col-lg-12">
        <g:if test="${sighting && !sighting?.error || !sighting}">
            <form id="sightingForm" action="${g.createLink(controller:'submitSighting', action:'upload')}" method="POST">
                <input type="hidden" name="occurrenceID" id="occurrenceID" value="${sighting?.occurrenceID}"/>
                <input type="hidden" name="userId" id="occurrenceID" value="${sighting?.userId?:user?.userId}"/>
                <input type="hidden" name="recordedBy" id="occurrenceID" value="${sighting?.recordedBy?:user?.userDisplayName}"/>
                <!-- Species -->
                <div class="boxed-heading" id="species" data-content="Species">
                    <div class="row">
                        <div id="" class="col-sm-5 col-md-4">
                            <div id="taxonDetails" class="well well-small" style="display: none">
                                <table class="hidden">
                                    <tr>
                                        <td><img src="" class="speciesThumbnail" alt="thumbnail image of species" style="width:75px; height:75px;"/></td>
                                        <td>
                                            <div class="sciName">
                                                <a href="" class="tooltips" title="view species page" target="BIE">species name</a>
                                            </div>
                                            <div class="commonName">common name</div>
                                        </td>
                                    </tr>
                                </table>
                                <div class="row">
                                    <div class="col-sm-4">
                                        <img src="${resource(dir: 'images', file: 'noImage.jpg')}" width="75" class="speciesThumbnail" alt="thumbnail image of species" style="width:75px; height:75px;"/>
                                    </div>
                                    <div class="col-sm-8">
                                        <div class="sciName">
                                            <a href="" class="tooltips" title="view species page" target="BIE">species name</a>
                                        </div>
                                        <div class="commonName">common name</div>
                                    </div>
                                </div>
                                <input type="hidden" name="taxonConceptID" id="guid" value="${taxon?.taxonConceptID}"/>
                                <input type="hidden" name="scientificName" id="scientificName" value="${taxon?.scientificName}"/>
                                <input type="hidden" name="commonName" id="commonName" value="${taxon?.commonName}"/>
                                <input type="hidden" name="kingdom" id="kingdom" value="${taxon?.kingdom}"/>
                                <input type="hidden" name="family" id="family" value="${taxon?.family}"/>
                                %{--<input type="hidden" name="identificationVerificationStatus" id="identificationVerificationStatus" value="${taxon?.identificationVerificationStatus}"/>--}%
                                %{--<a href="#" class="close removeHide" title="remove this item"><span aria-hidden="true">&times;</span></a>--}%
                            </div>
                            <div  class="well well-small" id="noSpecies">
                                <div class="row" style="font-size:15px;">
                                    <div class="col-sm-3">
                                        <i class="fa fa-image" style="font-size:36px; margin-right:10px;"></i>
                                    </div>
                                    <div class="col-sm-9">
                                        No species selected
                                    </div>
                                </div>
                            </div>
                            <div id="tagsBlock"></div>
                        </div>
                        <div class="col-sm-7 col-md-8">
                            <div id="showConfident" class="form-group">
                                <label for="speciesLookup">
                                    <div id="noTaxa" style="display: inherit;">Type a scientific or common name into the box below and choose from the auto-complete list.</div>
                                    <div id="matchedTaxa" style="display: none;">Not the right species? To <b>change</b> identification, type a scientific
                                    or common name into the box below and choose from the auto-complete list.</div>
                                </label>
                                <input class="form-control ${hasErrors(bean:sighting,field:'scientificName','validationErrors')}" id="speciesLookup" type="text" placeholder="Start typing a species name (common or latin)">
                            </div>
                            <div id="showUncertain" class="form-group">
                                <div>How confident are you with the species identification?
                                    <g:set var="confidenceGuess" value="${(taxon?.guid) ? 'confident' : 'uncertain' }"/>
                                    <g:radioGroup name="identificationVerificationStatus" labels="['Confident','Uncertain']" values="['confident','uncertain']" value="${sighting?.identificationVerificationStatus?.toLowerCase()?:confidenceGuess}" >
                                        <span style="white-space:nowrap;">${it.radio}&nbsp;${it.label}</span>
                                    </g:radioGroup>
                                </div>
                            </div>
                            <div id="identificationChoice" class="form-group">
                                <label for="speciesGroups">(Optional) Tag this sighting with species group and/or sub-group:</label>
                                <div class="row">
                                    <div class="col-sm-6">
                                        <g:select name="tag" from="${speciesGroupsMap?.keySet()}" id="speciesGroups" class="form-control input-sm ${hasErrors(bean:sighting,field:'scientificName','validationErrors')}" noSelection="['':'-- Species group --']"/>
                                    </div>
                                    <div class="col-sm-6">
                                        <g:select name="tag" from="${[]}" id="speciesSubgroups" class="form-control input-sm" noSelection="['':'-- Subgroup (select a group first) --']"/>
                                    </div>
                                </div>
                            </div>
                            <g:if test="${grailsApplication.config.include.taxonoverflow}">
                                <div id="speciesMisc" class="hide">
                                    <label for="requireIdentification" class="checkbox">
                                        <g:checkBox id="requireIdentification" name="requireIdentification"
                                                    value="${(sighting?.requireIdentification)}"/>
                                        Ask the Taxon-Overflow community to assist with or confirm the identification (requires a photo of the sighting)
                                    </label>
                                </div>
                            </g:if>
                        </div>

                        <g:if test="${grailsApplication.config.identify.enabled.toBoolean()}">
                            <div id="identifyHelpTrigger">Unsure of the species name? Try the location-based <a href="#identifyHelpModal" class="identifyHelpTrigger">species suggestion tool</a></div>
                        </g:if>
                    </div>
                </div>

                <!-- Media -->


                <div class="boxed-heading" id="media" data-content="Images">
                    <g:if test="${grailsApplication.config.disableImageUploads}">
                        <h4>Image uploads are temporarily disabled</h4>
                        <p>Our image server is currently undergoing maintenance. Please check back later.</p>
                    </g:if>
                    <g:else>
                        <!-- The fileinput-button span is used to style the file input field as button -->
                        <span class="btn btn-success fileinput-button" title="Select one or more photos to upload (you can also simply drag and drop files onto the page).">
                            <i class="icon icon-white icon-plus"></i>
                            <span>Add files...</span>
                            <!-- The file input field used as target for the file upload widget -->
                            <input id="fileupload" type="file" name="files[]" multiple>
                        </span>
                        <span style="display: inline-block;">Optional. Add one or more images. Image metadata will be used to automatically set date and location fields (where available)
                            <br>Hint: you can drag and drop files onto this window</span>
                        <br>
                        <br>
                        <!-- The container for the uploaded files -->
                        <div id="files" class="files"></div>
                        <div id="imageLicenseDiv" class=" form-horizontal">
                            <div class="form-group">
                                <label for="imageLicense" class="col-sm-2 control-label">Licence:</label>
                                <div class="col-sm-4">
                                    <g:select from="${grailsApplication.config.sighting.licenses}" name="imageLicense" class="form-control input-sm" id="imageLicense" value="${sighting?.multimedia ? sighting?.multimedia?.get(0)?.license : ''   }"/>
                                </div>
                            </div>
                        </div>
                    </g:else>
                </div>

                <!-- Location -->
                <div class="boxed-heading" id="location" data-content="Location">
                    <div class="row">
                        <div class="col-sm-6" id="mapWidget">
                            <div class="row">
                                <div class="col-sm-5">
                                    <button class="btn btn-default" id="useMyLocation">
                                        <i class="fa fa-location-arrow fa-lg" style="margin-left:-2px;margin-right:2px;"></i> My location <r:img uri="/images/spinner.gif" class="spinner0" style="display:none;height: 18px;"/>
                                    </button>
                                    <span class="pull-right">
                                        <span class="badge" style="font-size:14px;margin-top:4px;"> OR </span>
                                    </span>
                                </div>
                                <div class="col-sm-7">
                                    <div class="input-group">
                                        <input class="form-control" id="geocodeinput" type="text" placeholder="Enter an address, location or lat/lng">
                                        <span class="input-group-btn">
                                            <button id="geocodebutton" class="btn btn-default"><i class="fa fa-search"></i></button>
                                        </span>
                                    </div><!-- /input-group -->
                                </div>
                            </div>
                            <div style="position:relative;">
                                <div id="map" style="width: 100%; height: 280px"></div>
                                <div class="" id="mapTip">Hint: drag the marker to fine-tune your location
                                    <img class="drag" id="markerIcon" src="${g.createLink(uri:'/js/leaflet-0.7.3/images')}/marker-icon.png" alt="marker icon" />
                                </div>
                            </div>

                        </div>
                        <div class="col-sm-6" style="margin-bottom: 0px;">
                            <table class="formInputTable">
                                <tr>
                                    <td width="30%"><label for="decimalLatitude">Latitude (decimal):</label></td>
                                    <td width="70%"><input type="text" name="decimalLatitude" id="decimalLatitude" class="form-control ${hasErrors(bean:sighting,field:'decimalLatitude','validationErrors')}" value="${sighting?.decimalLatitude}"/></td>
                                </tr>
                                <tr>
                                    <td><label for="decimalLongitude">Longitude (decimal):</label></td>
                                    <td><input type="text" name="decimalLongitude" id="decimalLongitude" class="form-control ${hasErrors(bean:sighting,field:'decimalLongitude','validationErrors')}" value="${sighting?.decimalLongitude}"/></td>
                                </tr>
                                <tr>
                                    <td><label for="coordinateUncertaintyInMeters">Accuracy (metres):</label></td>
                                    <td><g:select from="${grailsApplication.config.accuracyValues?:[0,10,50,100,500,1000,10000]}" id="coordinateUncertaintyInMeters" class="form-control  ${hasErrors(bean:sighting,field:'coordinateUncertaintyInMeters','validationErrors')}" name="coordinateUncertaintyInMeters" value="${sighting?.coordinateUncertaintyInMeters?:50}" noSelection="['':'--']"/></td>
                                </tr>
                                <tr>
                                    <td><label for="georeferenceProtocol">Source of coordinates:</label></td>
                                    <td><g:select from="${coordinateSources}" id="georeferenceProtocol" class="form-control " name="georeferenceProtocol" value="${sighting?.georeferenceProtocol}"/></td>
                                </tr>
                                <tr>
                                    <td><label for="locality">Matched locality:</label></td>
                                    <td><textarea id="locality" name="locality" class="form-control disabled" rows="3">${sighting?.locality}</textarea></td>
                                </tr>
                                <tr>
                                    <td><label for="locationRemark">Location notes:</label></td>
                                    <td><textarea id="locationRemark" name="locationRemark" class="form-control" rows="3" value="${sighting?.decimalLatitude}">${sighting?.locationRemark}</textarea></td>
                                </tr>
                                <tr>
                                    <td><label for="locationRemark">Saved locations:</label></td>
                                    <td>
                                        <div class="input-group">
                                            <g:select name="bookmarkedLocations" id="bookmarkedLocations" class="form-control " from="${[]}" optionKey="" optionValue="" noSelection="['':'-- saved locations --']"/>
                                            <span class="input-group-btn">
                                                <button id="bookmarkLocation" class="btn btn-default disabled" disabled="disabled">Save this location</button>
                                            </span>
                                        </div><!-- /input-group -->
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Details -->
                <div class="boxed-heading" id="details" data-content="Details">
                    <div class="row">
                        <div class="col-sm-6">
                            <table class="formInputTable form-inline">
                                <tr >
                                    <td><label for="dateStr">Date:</label></td>
                                    %{--<td id="eventDatePicker" class="${hasErrors(bean:sighting,field:'eventDate','validationErrors')}"><si:customDatePicker name="eventDate" id="eventDate" class="form-control" relativeYears="[0..-50]" noSelection="['':'--']" precision="day" placeholder="DD-MM-YYYY" value="${sighting?.eventDate}" default="${(sighting) ? sighting?.eventDate?:'none' : new Date()}"/></td>--}%
                                    <td id="eventDatePicker" class="${hasErrors(bean:sighting,field:'eventDate','validationErrors')}">
                                        <div class="form-group">
                                            <div class='input-group date' id='datetimepicker1'>
                                                <input type="text" id="dateStr" name="dateStr" class="form-control" placeholder="DD-MM-YYYY" value="${si.getDateTimeValue(date: sighting?.eventDate, part: 'date')}"/>
                                                <span class="input-group-addon">
                                                    <span class="fa fa-calendar"></span>
                                                </span>
                                            </div>
                                        </div>
                                        </td>
                                    <td><span class="helphint">* required</span></td>
                                </tr>
                                <tr >
                                    <td><label for="timeStr">Time:</label></td>
                                    <td>
                                        <div class="form-group">
                                            <div class='input-group date' id='datetimepicker2'>
                                                <input type='text' id="timeStr" name="timeStr" class="form-control" placeholder="HH:MM" value="${si.getDateTimeValue(date: sighting?.eventDate, part: 'time')}"/>
                                                <span class="input-group-addon">
                                                    <span class="fa fa-clock-o"></span>
                                                </span>
                                            </div>
                                        </div>
                                    </td>
                                    <td><span class="helphint">24 hour format</span></td>
                                </tr>
                                <tr>
                                    <td><label for="individualCount">Individuals:</label></td>
                                    <td><g:select from="${1..99}" name="individualCount" class="input-sm form-control smartspinner" value="${sighting?.individualCount}" data-validation-engine="validate[custom[integer], min[1]]" id="individualCount"/></td>
                                    <td><span class="helphint">How many did you see?</span></td>
                                </tr>
                            </table>
                            <input type="hidden" name="timeZoneOffset" id="timeZoneOffset" value="${sighting?.timeZoneOffset}"/>
                            <input type="hidden" name="eventDate" id="eventDate" value="${sighting?.eventDate}"/>
                        </div>
                        <div class="col-sm-6">
                            <section class="sightings-block form-horizontal" style="vertical-align: top;">
                                <div class="form-group">
                                    <label for="occurrenceRemarks" class="col-sm-2 control-label">Notes: </label>
                                    <div class="col-sm-10">
                                        <textarea name="occurrenceRemarks" rows="4" cols="90" class="form-control" id="occurrenceRemarks">${sighting?.occurrenceRemarks}</textarea>
                                    </div>
                                </div>
                            </section>
                        </div>
                    </div>
                </div>

                <div id="submitArea">
                    <div id="termsOfUse">Please read the <a href="${grailsApplication.config.termsOfUseUrl}" target="_blank">
                        terms of use</a>
                        <g:if test="${grailsApplication.config.privacyPolicyUrl}"> and <a href="${grailsApplication.config.privacyPolicyUrl}" target="_blank">privacy policy</a></g:if>
                        before submitting your sighting</div>
                    <div id="submitWrapper"><input type="submit" id="formSubmit" class="btn btn-primary btn-lg"  value="${actionName == 'edit' ? 'Update' : 'Submit'} Record"/></div>
                </div>

                <%-- Template HTML used by JS code via .clone() --%>
                <div class="hide imageRow row" id="uploadActionsTmpl">
                    <div class="col-sm-2"><span class="preview pull-right"></span></div>
                    <div class="col-sm-10">
                        <div class="metadata media">
                            Filename: <span class="filename"></span>
                            %{--<input type="hidden" class="media" value=""/>--}%
                            %{--TODO: convert to a proper form and allow user to change these and other values via a hide/show option--}%
                            <input type="hidden" class="title" value=""/>
                            <input type="hidden" class="format" value=""/>
                            <input type="hidden" class="identifier" value=""/>
                            <input type="hidden" class="imageId" value=""/>
                            <input type="hidden" class="license" value=""/>
                            <input type="hidden" class="created" value=""/>
                            <input type="hidden" class="creator" value=""/>
                        </div>
                        <div class="metadata">
                            Image date: <span class="imgDate">not available</span>
                        </div>
                        <div class="metadata">
                            GPS coordinates: <span class="imgCoords">not available</span>
                        </div>
                        %{--<button class="btn btn-small imageDate">Use image date</button>--}%
                        %{--<button class="btn btn-small imageLocation">Use image location</button>--}%
                        <button class="btn btn-sm btn-info imageData" title="No metadata found" disabled>Use image metadata</button>
                        <button class="btn btn-sm btn-danger imageRemove" title="remove this image">Remove image</button>
                    </div>
                    <div class="error hide"></div>
                </div>
                </div><!-- /#uploadActionsTmpl-->
                <!-- Modal -->
                <div id="identifyHelpModal" class="modal fade">
                    <div class="modal-dialog modal-lg">
                        <div class="modal-content">
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                                <h3 id="identifyHelpModalLabel">See species known to occur in a particular location</h3>
                            </div>
                            <div class="modal-body">
                                <g:render template="/identify/widget_nomap"  />
                            </div>
                            <div class="modal-footer">
                                <div class="pull-left" style="margin-top:10px;">Searching for species within a <g:select name="radius" id="radius" class="select-mini" from="${[1,2,5,10,20]}" value="${defaultRadius?:5}"/>
                                km area - increase to see more species</div>
                                <button type="button" class="btn btn-default" data-dismiss="modal">Close</button>
                            </div>
                        </div><!-- /.modal-content -->
                    </div><!-- /.modal-dialog -->
                </div><!-- /#identifyHelpModal -->
            </form>
        </g:if>
    </div>
</div>
</body>
</html>