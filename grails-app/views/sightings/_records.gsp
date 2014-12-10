
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

<table class="table table-bordered table-condensed table-striped">
    <thead>
    <tr>
        <th>Record ID</th>
        <th>Identification</th>
        <th>Date</th>
        <th>User</th>
        <th>Location</th>
        <th>Images</th>
    </tr>
    </thead>
    <tbody>
    <g:each in="${sightings}" var="s">
        <tr>
            <td>${s.occurrenceID}</td>
            <td>${s.scientificName}<br>${s.tags?.join(', ')}</td>
            <td>${s.eventDate?.substring(0,10)}</td>
            <td>${s.userId}</td>
            <td>${s.locality} (${s.decimalLatitude}, ${s.decimalLongitude})</td>
            <td>
                <g:each in="${s.multimedia}" var="i">
                    <g:if test="${i.identifier}"><img src="${i.identifier}" alt="species thumbnail" style="max-height: 100px;  max-width: 100px;"/></g:if>
                </g:each>
            </td>
        </tr>
    </g:each>
    </tbody>
</table>