<%@ page import="org.codehaus.groovy.grails.web.json.JSONObject" %>
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
<g:if test="${sightings?.totalRecords > 0}">
    <div id="recordsPaginateSummary">
        <g:set var="total" value="${sightings.totalRecords}"/>
        <g:set var="fromIndex" value="${(params.offset) ? (params.offset.toInteger() + 1) : 1}"/>
        <g:set var="toIndex" value="${((params.offset?:0).toInteger() + (params.max?:10).toInteger())}"/>
        Displaying records ${fromIndex} to ${(toIndex < total) ? toIndex : total} of ${total}
    </div>
</g:if>
<table class="table table-bordered table-condensed table-striped">
    <thead>
    <tr>
        <th style="width:20%;">Identification</th>
        <th>Date submitted</th>
        <th style="width:30%;">Location</th>
        <th>Action</th>
        <th>Images</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${sightings.records}" var="s">
        <tr>
            <td>
                <span class="speciesName">${s.scientificName}</span> ${raw((s.commonName) ? '<br>' + s.commonName: '')} ${raw((s.tags) ? '<br>' + s.tags.join(', ') : '')}
            </td>
            <td>
                <span style="white-space:nowrap;">
                    <g:if test="${!org.codehaus.groovy.grails.web.json.JSONObject.NULL.equals(s.get("eventDate"))}">
                        ${(s.eventDate.size() >= 10) ? s.eventDate?.substring(0,10) : s.eventDate}
                    </g:if>
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
            <td>
                <g:if test="${s.occurrenceID}">
                    <a href="http://biocache.ala.org.au/occurrence/${s.occurrenceID}">View public record</a>
                </g:if>
                <g:if test="${user?.userId == s.userId || auth.ifAnyGranted(roles:'ROLE_ADMIN', "1")}">
                    <div class="actionButtons">
                        <a href="${g.createLink(controller: 'submitSighting', action:'edit', id: s.occurrenceID)}" class="btn btn-small editBtn" data-recordid="occurrenceID">Edit</a>
                        <button class="btn btn-small deleteRecordBtn" data-recordid="${s.occurrenceID}">Delete</button>
                    </div>
                </g:if>
                <g:if test="${user?.userId == s.userId}"></g:if>
            </td>
            <td>
                <g:each in="${s.multimedia}" var="i">
                    <g:if test="${i.identifier}"><img src="${i.identifier}" alt="species thumbnail" style="max-height: 100px;  max-width: 100px;"/></g:if>
                </g:each>
            </td>
        </tr>
    </g:each>
    <r:script>
        $(function () {
            //
            $('.deleteRecordBtn').click(function(e) {
                e.preventDefault();
                var id = $(this).data('recordid');
                if (confirm("Are you sure you want to delete this record?")) {
                    window.location = "${g.createLink(controller: 'sightings', action:'delete')}/" + id;
                }
            });
        });
    </r:script>
    </tbody>
</table>
<div class="pagination">
    <g:paginate total="${sightings.totalRecords?:0}" max="${params.pageSize?:10}" offset="${params.start?:0}"/>
</div>