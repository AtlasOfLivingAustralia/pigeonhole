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
    <meta name="layout" content="main"/>
    <title>Report a sighting | Atlas of Living Australia</title>
    <r:require modules="fileuploads, exif, moment, alaAutocomplete, pigeonhole, datepicker, qtip, udraggable, fontawesome, purl, submitSighting"/>
    <r:script disposition="head">
        // global var to pass in GSP/Grails values into external JS files
        GSP_VARS = {
            biocacheBaseUrl: "${(grailsApplication.config.biocache.baseUrl)}",
            bieBaseUrl: "${(grailsApplication.config.bie.baseUrl)}",
            uploadUrl: "${createLink(uri:"/ajax/upload")}",
            bookmarksUrl: "${createLink(controller:"ajax", action:"getBookmarkLocations")}",
            saveBookmarksUrl: "${createLink(controller:"ajax", action:"saveBookmarkLocation")}",
            //bookmarks: ${(bookmarks).encodeAsJson()?:'{}'},
            guid: "${taxon?.guid}",
            speciesGroups: ${(speciesGroupsMap).encodeAsJson()?:'{}'}, // TODO move this to an ajax call (?)
            leafletImagesDir: "${g.createLink(uri:'/js/leaflet-0.7.3/images')}",
            user: ${(user).encodeAsJson()?:'{}'},
            sightingBean: ${(sighting).encodeAsJson()?:'{}'}
        };
    </r:script>
</head>
<body class="nav-species">
<g:render template="/topMenu" />
<h2>Report a Sighting</h2>
<g:set var="errorsShown" value="${false}"/>
<g:hasErrors bean="${sighting}">
    <g:set var="errorsShown" value="${true}"/>
    <div class="container-fluid">
        <div class="alert alert-error">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${raw(flash.message)}
            <g:eachError var="err" bean="${sighting}">
                <li><g:message code="sighting.field.${err.field}"/> - <g:fieldError bean="${sighting}"  field="${err.field}"/></li>
            </g:eachError>
        </div>
    </div>
</g:hasErrors>
<g:if test="${!errorsShown && (flash.message || sighting?.error)}">
    <div class="container-fluid">
        <div class="alert alert-error">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${raw(flash.message)?:sighting?.error}
        </div>
    </div>
</g:if>
<g:if test="${sighting && !sighting?.error || !sighting}">
<form id="sightingForm" action="${g.createLink(controller:'submitSighting', action:'upload')}" method="POST">
    <input type="hidden" name="occurrenceID" id="occurrenceID" value="${sighting?.occurrenceID}"/>
    <input type="hidden" name="userId" id="occurrenceID" value="${sighting?.userId?:user?.userId}"/>
    <input type="hidden" name="userDisplayName" id="occurrenceID" value="${sighting?.userDisplayName?:user?.userDisplayName}"/>
    <!-- Species -->
    <div class="boxed-heading" id="species" data-content="Species">
        <div class="row-fluid">
            <div id="speciesOne">
                <div id="taxonDetails" class="well well-small" style="display: none;">
                    <table>
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
                    <input type="hidden" name="taxonConceptID" id="guid" value="${taxon?.taxonConceptID}"/>
                    <input type="hidden" name="scientificName" id="scientificName" value="${taxon?.scientificName}"/>
                    <input type="hidden" name="commonName" id="commonName" value="${taxon?.commonName}"/>
                    <input type="hidden" name="kingdom" id="kingdom" value="${taxon?.kingdom}"/>
                    <input type="hidden" name="family" id="family" value="${taxon?.family}"/>
                    %{--<input type="hidden" name="identificationVerificationStatus" id="identificationVerificationStatus" value="${taxon?.identificationVerificationStatus}"/>--}%
                    %{--<a href="#" class="remove" title="remove this item"><i class="remove icon-remove">&nbsp;</i></a>--}%
                </div>
                <div id="tagsBlock"></div>
            </div>
            <div id="speciesTwo">
                <div id="showConfident" class="">
                    <div id="noTaxa" style="display: inherit;">Type a scientific or common name into the box below and choose from the auto-complete list.</div>
                    <div id="matchedTaxa" style="display: none;">Not the right species? To change identification, type a scientific
                    or common name into the box below and choose from the auto-complete list.</div>
                    <input class="input-xlarge typeahead ${hasErrors(bean:sighting,field:'scientificName','validationErrors')}" id="speciesLookup" type="text">
                </div>
                <div id="identificationChoice" class="hide">
                    <div>How confident are you with the species identification?
                    <g:radioGroup name="identificationVerificationStatus" labels="['Confident','Uncertain']" values="['confident','uncertain']" value="${sighting?.identificationVerificationStatus?.toLowerCase()?:'confident'}" >
                        <span style="white-space:nowrap;">${it.radio}&nbsp;${it.label}</span>
                    </g:radioGroup>
                    </div>
                </div>
                <div id="showUncertain" class=" ">
                    <div>(Optional) Tag this sighting with species group and/or sub-group:</div>
                    <g:select name="tag" from="${speciesGroupsMap?.keySet()}" id="speciesGroups" class="slim ${hasErrors(bean:sighting,field:'scientificName','validationErrors')}" noSelection="['':'-- Species group --']"/>
                    <g:select name="tag" from="${[]}" id="speciesSubgroups" class="slim" noSelection="['':'-- Subgroup (select a group first) --']"/>
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
            <a href="#identifyHelpModal" role="button" class="btn btn-primary" data-toggle="modal">Help me identify my sighting</a>
        </div>
    </div>

    <!-- Media -->
    <div class="boxed-heading" id="media" data-content="Media">
        <!-- The fileinput-button span is used to style the file input field as button -->
        <button class="btn btn-success fileinput-button tooltips" title="Select one or more photos to upload (you can also simply drag and drop files onto the page).">
            <i class="icon icon-white icon-plus"></i>
            <span>Add files...</span>
            <!-- The file input field used as target for the file upload widget -->
            <input id="fileupload" type="file" name="files[]" multiple>
        </button>
        <span style="display: inline-block;">Optional. Add one or more images. Image metadata will be used to automatically set date and location fields (where available)
            <br>Hint: you can drag and drop files onto this window</span>
        <br>
        <br>
        <!-- The container for the uploaded files -->
        <div id="files" class="files"></div>
        <div id="imageLicenseDiv" class="hide">
            <label for="imageLicense">Licence:</label>
            <g:select from="${grailsApplication.config.sighting.licenses}" name="imageLicense" class="slim" id="imageLicense" value="${sighting?.multimedia?.get(0)?.license}"/>
        </div>
    </div>

    <!-- Location -->
    <div class="boxed-heading" id="location" data-content="Location">
        <div class="row-fluid">
            <div class="span6" id="mapWidget">
                <div class="form-horizontal">
                    <button class="btn" id="useMyLocation">
                        <i class="fa fa-location-arrow fa-lg" style="margin-left:-2px;margin-right:3px;"></i> Use my location <r:img uri="/images/spinner.gif" class="spinner0 hide" style="height: 18px;"/>
                    </button>
                    &nbsp;<span class="badge badge-infoX"> OR </span>&nbsp;
                    <div class="input-append">
                        <input class="input-large" id="geocodeinput" type="text" placeholder="Enter an address, location or lat/lng">
                        <button id="geocodebutton" class="btn">Lookup</button>
                    </div>
                </div>
                <div style="position:relative;">
                    <div id="map" style="width: 100%; height: 280px"></div>
                    <div class="" id="mapTips">Hint: drag the marker to fine-tune your location
                        <img class="drag" id="markerIcon" src="${g.createLink(uri:'/js/leaflet-0.7.3/images')}/marker-icon.png" alt="marker icon" />
                    </div>
                </div>

            </div>
            <div class="span6" style="margin-bottom: 0px;">
                <table class="formInputTable">
                    <tr>
                        <td><label for="decimalLatitude">Latitude (decimal):</label></td>
                        <td><input type="text" name="decimalLatitude" id="decimalLatitude" class="input-auto ${hasErrors(bean:sighting,field:'decimalLatitude','validationErrors')}" value="${sighting?.decimalLatitude}"/></td>
                    </tr>
                    <tr>
                        <td><label for="decimalLongitude">Longitude (decimal):</label></td>
                        <td><input type="text" name="decimalLongitude" id="decimalLongitude" class="input-auto ${hasErrors(bean:sighting,field:'decimalLongitude','validationErrors')}" value="${sighting?.decimalLongitude}"/></td>
                    </tr>
                    <tr>
                        <td><label for="coordinateUncertaintyInMeters">Accuracy (metres):</label></td>
                        <td><g:select from="${grailsApplication.config.accuracyValues?:[0,10,50,100,500,1000,10000]}" id="coordinateUncertaintyInMeters" class="slim ${hasErrors(bean:sighting,field:'coordinateUncertaintyInMeters','validationErrors')}" name="coordinateUncertaintyInMeters" value="${sighting?.coordinateUncertaintyInMeters?:50}" noSelection="['':'--']"/></td>
                    </tr>
                    <tr>
                        <td><label for="georeferenceProtocol">Source of coordinates:</label></td>
                        <td><g:select from="${coordinateSources}" id="georeferenceProtocol" class="slim" name="georeferenceProtocol" value="${sighting?.georeferenceProtocol}"/></td>
                    </tr>
                    <tr>
                        <td><label for="locality">Matched locality:</label></td>
                        <td><textarea id="locality" name="locality" class="disabled" rows="3">${sighting?.locality}</textarea></td>
                    </tr>
                    <tr>
                        <td><label for="locationRemark">Location notes:</label></td>
                        <td><textarea id="locationRemark" name="locationRemark" class="" rows="3" value="${sighting?.decimalLatitude}">${sighting?.locationRemark}</textarea></td>
                    </tr>
                    <tr>
                        <td><label for="locationRemark">Saved locations:</label></td>
                        <td><div class="form-horizontal"><g:select name="bookmarkedLocations" id="bookmarkedLocations" class="" from="${[]}" optionKey="" optionValue="" noSelection="['':'-- saved locations --']"/>
                            <button id="bookmarkLocation" class="btn  disabled" disabled="disabled">Save this location</button></div></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

    <!-- Details -->
    <div class="boxed-heading" id="details" data-content="Details">
        <div class="row-fluid">
            <div class="span6">
                <table class="formInputTable">
                    <tr >
                        <td><label for="eventDate">Date:</label></td>
                        <td id="eventDatePicker" class="${hasErrors(bean:sighting,field:'eventDate','validationErrors')}"><g:datePicker name="eventDate" id="eventDate" relativeYears="[0..-50]" noSelection="['':'--']" precision="day" placeholder="DD-MM-YYYY" value="${sighting?.eventDate}" default="${(sighting) ? sighting?.eventDate?:'none' : new Date()}"/></td>
                        <td><span class="helphint">* required</span></td>
                    </tr>
                    <tr >
                        <td><label for="eventDate_hour">Time:</label></td>
                        <td>
                            <g:select name="eventDate_hour" id="eventDate_hour" class="input-auto"  from="${(0..23).collect{it.toString().padLeft(2,'0')}}" value="${si.getTimeValue(date: sighting?.eventDate, part: Calendar.HOUR)}"/>
                            :
                            <g:select name="eventDate_minute" id="eventDate_minute" class="input-auto"  from="${(0..59).collect{it.toString().padLeft(2,'0')}}" value="${si.getTimeValue(date: sighting?.eventDate, part: Calendar.MINUTE)}"/>
                        </td>
                        <td><span class="helphint">24 hour format</span></td>
                    </tr>
                    <tr>
                        <td><label for="individualCount">Individuals:</label></td>
                        <td><g:select from="${1..99}" name="individualCount" class="slim input-auto smartspinner" value="${sighting?.individualCount}" data-validation-engine="validate[custom[integer], min[1]]" id="individualCount"/></td>
                        <td><span class="helphint">How many did you see?</span></td>
                    </tr>
                </table>
                <input type="hidden" name="timeZoneOffset" id="timeZoneOffset" value="${sighting?.timeZoneOffset}"/>
            </div>
            <div class="span6">
                <section class="sightings-block ui-corner-all" style="vertical-align: top;">
                    <label for="occurrenceRemarks" style="vertical-align: top;margin-top: 8px;margin-right: 5px;">Notes: </label>
                    <textarea name="occurrenceRemarks" rows="4" cols="90" id="occurrenceRemarks">${sighting?.occurrenceRemarks}</textarea>
                </section>
            </div>
        </div>
    </div>

    <div style="text-align: center;">
        <input type="submit" id="formSubmit" class="btn btn-large"  value="${actionName == 'edit' ? 'Update' : 'Submit'} Record"/>
    </div>

<%-- Template HTML used by JS code via .clone() --%>
    <div class="hide imageRow row-fluid" id="uploadActionsTmpl">
        <div class="span2"><span class="preview pull-right"></span></div>
        <div class="span10">
            <div class="metadata media">
                Filename: <span class="filename"></span>
                %{--<input type="hidden" class="media" value=""/>--}%
                %{--TODO: convert to a proper form and allow user to change these and other values via a hide/show option--}%
                <input type="hidden" class="title" value=""/>
                <input type="hidden" class="format" value=""/>
                <input type="hidden" class="identifier" value=""/>
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
            <button class="btn btn-small btn-info imageData" title="No metadata found" disabled>Use image metadata</button>
            <button class="btn btn-small btn-danger imageRemove" title="remove this image">Remove image</button>
        </div>
        <div class="error hide"></div>
    </div>
    </div><!-- /#uploadActionsTmpl-->

    <!-- Modal -->
    <div id="speciesBrowserModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="myModalLabel">Browse species images</h3>
        </div>
        <div class="modal-body">
            <div id="speciesImages"></div>
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            %{--<button class="btn btn-primary">Save changes</button>--}%
        </div>
    </div><!-- /#speciesBrowserModal -->
<!-- Modal -->
    <div id="identifyHelpModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="identifyHelpModalLabel" aria-hidden="true">
        <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
            <h3 id="identifyHelpModalLabel">Help with species identification</h3>
        </div>
        <div class="modal-body">
            The following page will guide you through the process of identiying a species of interest by allowing you to browse
            images of species from common "groups". The suggested species are selected from a list of species known to be found in the area
            you specify (via a simple map tool). Once you choose a candidate species you will be brought back to this page with the chosen
            species selected for you (note you will lose any data on this page, so do this step first).
        </div>
        <div class="modal-footer">
            <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
            <g:set var="thisUrl" value="${g.createLink(controller: params.controller, action: params.action, id: (params.action ==  'edit') ? params.id : '', absolute: true)}"/>
            <a href="${g.createLink(uri:'/identify?returnUrl=' + thisUrl )}" class="btn btn-primary">Proceed to Identification Help page</a>
        </div>
    </div><!-- /#identifyHelpModal -->

</form>
</g:if>
</body>
</html>