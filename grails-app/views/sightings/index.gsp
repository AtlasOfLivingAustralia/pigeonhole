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
  Date: 10/12/14
  Time: 12:09 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>${pageHeading}</title>
    <r:require modules="pigeonhole, jqueryMigrate, moment"/>
</head>
<body class="nav-species">
<g:render template="/topMenu" />
<h2>${pageHeading}</h2>
<g:if test="${flash.message?:flash.errorMessage}">
    <div class="container-fluid">
        <div class="alert ${(flash.errorMessage) ? 'alert-error' : 'alert-info'}">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${raw(flash.message?:flash.errorMessage)}
            <!-- ${flash.message = null} ${flash.errorMessage = null} -->
        </div>
    </div>
</g:if>
%{--${sightings} ${sightings.getClass()?.name}--}%
<div class="row-fluid" id="content">
    <div class="span12">
        <g:if test="${sightings && sightings.records}">
            <div id="sightingsBlurb">
                This is a simple list of the sightings
                <g:if test="${actionName == 'user' && params.id}">${user?.displayName?:'[unknown username]'} has submitted.</g:if>
                <g:elseif test="${actionName == 'user'}">you have submitted.</g:elseif>
                <g:elseif test="${actionName == 'index'}">submitted recently by users.</g:elseif>
                You can filter, sort and map sightings using the Atlas'
                <g:set var="biocacheLink" value="http://biocache.ala.org.au/occurrences/search?q=*:*&fq=data_resource_uid:dr364${(actionName != 'index' && user?.userId) ? '&fq=alau_user_id:' + user?.userId : ''}"/>
                <a href="${biocacheLink}">Occurrence explorer</a>.
                <div class=""><strong>Note:</strong> Sightings may take up to 24 hours to appear in the <a href="${biocacheLink}">Occurrence explorer</a> pages.</div>
            </div>
            <g:if test="${sightings?.totalRecords > 0}">
                <div id="sortWidget">Sort by:
                <g:select from="${grailsApplication.config.sortFields}" valueMessagePrefix="sort" id="sortBy" name="sortBy" value="${params.sort?:'lastUpdated'}"/>
                <g:select from="${['asc','desc']}" valueMessagePrefix="order" id="orderBy" name="orderBy" value="${params.order?:'desc'}"/>
                </div>
                <div id="recordsPaginateSummary">
                    <g:set var="total" value="${sightings.totalRecords}"/>
                    <g:set var="fromIndex" value="${(params.offset) ? (params.offset.toInteger() + 1) : 1}"/>
                    <g:set var="toIndex" value="${((params.offset?:0).toInteger() + (params.max?:10).toInteger())}"/>
                    Displaying records ${fromIndex} to ${(toIndex < total) ? toIndex : total} of ${g.formatNumber(number: total, format: "###,##0")}
                </div>
            </g:if>
            <table class="table table-bordered table-condensed table-striped" id="sightingsTable">
                <thead>
                <tr>
                    <th style="width:20%;">Identification</th>
                    <th>Sighting date</th>
                    <th style="width:30%;">Location</th>
                    <g:if test="${user?.userId && user.userId == s?.userId || auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}"><th>Action</th></g:if>
                    <th>Images</th>
                </tr>
                </thead>
                <tbody>
                <g:each in="${sightings.records}" var="s">
                    <tr>
                        <td>
                            <span class="speciesName">${s.scientificName}</span>
                            <div>${s.commonName}</div>
                            <g:if test="${s.tags}"><div style="margin-bottom: 5px;">
                                <g:each in="${s.tags}" var="t"><span class="label">${raw(t)}</span> </g:each>
                            </div></g:if>
                            <g:if test="${grailsApplication.config.showBiocacheLinks && s.occurrenceID}">
                                <a href="http://biocache.ala.org.au/occurrence/${s.occurrenceID}">View public record</a>
                            </g:if>
                            <a class="btn btn-default btn-mini flagBtn" href="#flagModal" role="button" data-occurrenceid="${s.occurrenceID}" title="Suggest this record might require confirmation/correction" style="font-size: 12px;font-weight:300;">
                                <i class="fa fa-flag"></i> flag</a>
                        </td>
                        <td>
                            <span style="white-space:nowrap;">
                                <g:if test="${!org.codehaus.groovy.grails.web.json.JSONObject.NULL.equals(s.get("eventDate"))}">
                                %{--${(s.eventDate.size() >= 10) ? s.eventDate?.substring(0,10) : s.eventDate}--}%
                                    <span class="eventDateFormatted" data-isodate="${s.eventDate}">${(s.eventDate.size() >= 10) ? s.eventDate?.substring(0,10) : s.eventDate}</span>
                                </g:if>
                                <g:set var="userNameMissing" value="User ${s.userId}"/>
                                <div>Recorded by: <a href="${g.createLink(mapping: 'spotter', id: s.userId)}" title="View other sightings by this user">${s.userDisplayName?:userNameMissing}</a></div>
                            </span>
                        </td>
                        <td>
                            ${s.locality}
                            <g:if test="${s.decimalLatitude && s.decimalLatitude != 'null' && s.decimalLongitude && s.decimalLongitude != 'null' }">
                                <div>
                                    Lat: ${s.decimalLatitude}<br>
                                    Lng: ${s.decimalLongitude}
                                </div>
                            </g:if>
                        </td>
                        <g:if test="${user?.userId && user?.userId == s?.userId || auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}"><td>
                            <div class="actionButtons">
                                <a href="${g.createLink(controller: 'submitSighting', action:'edit', id: s.occurrenceID)}" class="btn btn-small editBtn" data-recordid="occurrenceID"><i class="fa fa-pencil"></i> Edit</a>
                                <button class="btn btn-small deleteRecordBtn" data-recordid="${s.occurrenceID}"><i class="fa fa-trash"></i>&nbsp;Delete</button>
                            </div>
                        </td></g:if>
                        <td>
                            <g:each in="${s.multimedia}" var="i">
                                <g:if test="${i.thumbnailUrl?:i.identifier}">
                                    <a href="#imageModal" role="button" class="imageModal" data-imgurl="${i.identifier}" title="view full sized image" target="original"><img src="${i.thumbnailUrl?:i.identifier}" alt="sighting photo thumbnail" style="max-height: 100px;  max-width: 100px;"/></a>
                                </g:if>
                            </g:each>
                        </td>
                    </tr>
                </g:each>
                </tbody>
            </table>
            <div class="pagination">
                <g:set var="mappingName"><g:if test="${actionName == 'index'}">recent</g:if><g:elseif test="${actionName == 'user' && params.id}">spotter</g:elseif><g:else>mine</g:else></g:set>
                <g:paginate total="${sightings.totalRecords?:0}" mapping="${mappingName}" id="${params.id}"/>
            </div>
            <!-- Image Modal -->
            <div id="imageModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                    <h3 id="myModalLabel">Sighting image</h3>
                </div>
                <div class="modal-body">
                    <img id="originalImage" src="${g.resource(dir:'images',file:'noImage.jpg')}" alt="original image file for sighting"/>
                </div>
                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                </div>
            </div>
             <!-- Flag Modal -->
            <div id="flagModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="flagModalLabel" aria-hidden="true">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
                    <h3 id="flagModalLabel">Flag sighting</h3>
                </div>
                <div class="modal-body">
                    <div>Please provide a reason category for why this record requires reviewing:</div>
                    <div class="requiredBlock">
                        <g:select from="${grailsApplication.config.flag?.issues}" id="issueReason" name="issueReason" valueMessagePrefix="reason" noSelection="['':'-- choose a reason--']" class="span8"/>
                        <i class="fa fa-asterisk"></i>
                    </div>
                    <div>Add a short comment describing the reason for flagging this record:</div>
                    <div class="requiredBlock">
                        <g:textArea name="comment" id="comment" rows="8" class="span8"/>
                        <i class="fa fa-asterisk"></i>
                    </div>
                    <input type="hidden" id="occurrenceId" name="occurrenceId" value=""/>
                </div>
                <div class="modal-footer">
                    <button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
                    <button id="submitFlagIssue" class="btn btn-primary">Submit</button>
                </div>
            </div>
            <r:script>
                $(function () {
                    // delete record button confirmation
                    $('.deleteRecordBtn').click(function(e) {
                        e.preventDefault();
                        var id = $(this).data('recordid');
                        if (confirm("Are you sure you want to delete this record?")) {
                            window.location = "${g.createLink(controller: 'sightings', action:'delete')}/" + id;
                        }
                    });

                    // Use Moment.js to output time in correct timezone
                    // ISO date stores time in UTC but this gets outputted in local time for user
                    // not perfect but fixes issues where users complain their sighting date/time is wrong
                    // due to UTC timezone storage
                    $.each($('.eventDateFormatted'), function(i, el) {
                        var isoDate = $(this).data('isodate');
                        var outputDate = moment(isoDate).format("DD-MM-YYYY, HH:mm");
                        $(this).text(outputDate);
                    });

                    $('#sortBy').change(function(e) {
                        e.preventDefault();
                        window.location = "?sort=" + $(this).val();
                    });

                     $('#orderBy').change(function(e) {
                        e.preventDefault();
                        window.location = "?sort=${params.sort?:'lastUpdated'}&order=" + $(this).val();
                    });

                    $('.imageModal').click(function(e) {
                         e.preventDefault();
                         var url = $(this).data('imgurl');
                         var initialUrl = $('#originalImage').attr('src');
                         if (url) {
                            $('#imageModal').modal('show').on('shown', function () {
                                $('#originalImage').attr('src', url);
                            }).on('hidden', function () {
                                $('#originalImage').attr('src', initialUrl);
                            });
                         }
                    });

                    var reasonBorderCss = $('#issueReason').css('border');
                    var commentBorderCss = $('#comment').css('border');

                    $('.flagBtn').click(function(e) {
                        e.preventDefault();
                        var occurrenceId = $(this).data('occurrenceid');
                        $('#flagModal').modal('show').on('shown', function (event) {
                            $(this).find('#occurrenceId').val(occurrenceId);
                        }).on('hidden', function (event) {
                            $(this).find('#occurrenceId').val('');
                            $(this).find('#issueReason').val('').css('border', reasonBorderCss);
                            $(this).find('#comment').val('').css('border', commentBorderCss);
                        });
                    });

                    $('#submitFlagIssue').click(function(e) {
                        e.preventDefault();
                        var issueReason = $('#issueReason').val();
                        var comment = $('#comment').val();

                        if (issueReason && comment) {
                            alert("functionality coming soon");
                            $('#flagModal').modal('hide'); // TODO move to ajax async 'always' closure
                        } else {
                            if (!issueReason) {
                                $('#issueReason').css('border','1px solid red');
                                $('#issueReason').on('change', function(e){
                                    $(this).css('border', reasonBorderCss);
                                });
                            }
                            if (!comment) {
                                $('#comment').css('border','1px solid red');
                                $('#comment').on('change', function(e){
                                    $(this).css('border', commentBorderCss);
                                });
                            }
                            alert('Please fill in required fields (*)')
                        }

                    });
                });
            </r:script>
        </g:if>
        <g:elseif test="${sightings && sightings instanceof org.codehaus.groovy.grails.web.json.JSONObject && sightings.has('error')}">
            <div class="container-fluid">
                <div class="alert alert-error">
                    <b>Error:</b> ${sightings.error} (${sightings.exception})
                </div>
            </div>
        </g:elseif>
        <g:else>
            No sightings found
        </g:else>
    </div>
</div>
</body>
</html>