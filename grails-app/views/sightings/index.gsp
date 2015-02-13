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
    <r:require modules="jqueryMigrate, moment"/>
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
            <g:render template="records"/>
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