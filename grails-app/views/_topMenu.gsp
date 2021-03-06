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
<!-- params: ${params.controller} || ${params.action} -->
<!--  vars: ${controllerName} || ${actionName} -->
<div class="row titleRow">
    <div class="col-sm-4">
        <div class="pull-left">
            <h2>${pageHeading}</h2>
        </div>
    </div>
    <div class="col-sm-8">
        <div id="sightingLinks" class="pull-right">
            <g:if test="${user && params.action == 'user' && params.controller == 'sightings'}">
                <span class="showMySightings">My sightings</span>
            </g:if>
            <g:else>
                <a href="${g.createLink(uri:'/mine')}" class="showMySightings">My sightings</a>
            </g:else>
            |
            <g:if test="${actionName == 'index' && controllerName == 'sightings'}">
                <a href="${g.createLink(uri:'/sightings/index')}" class="showMySightings adminLink">Recent sightings</a>
            </g:if>
            <g:else>
                <a href="${g.createLink(uri:'/recent')}" class="showMySightings">Recent sightings</a>
            </g:else>
            <g:if test="${params.controller != 'submitSighting'}">
                | <a href="${biocacheLink}">Occurrence explorer</a>
            </g:if>
        &nbsp;&nbsp;
            <g:if test="${params.controller != 'submitSighting'}">
                <a href="${g.createLink(uri:'/')}" class="btn btn-primary btn-small" style="font-size: 13px;" title="Login required" ><i class="fa fa-binoculars fa-inverse"></i>&nbsp;&nbsp;Record a sighting</a>
            </g:if>
        </div>
    </div>
</div>
