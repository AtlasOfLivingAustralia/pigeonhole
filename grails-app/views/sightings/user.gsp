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
  Time: 2:09 PM
  To change this template use File | Settings | File Templates.
--%>

<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Your sightings</title>
    <r:require modules="jqueryMigrate"/>
    <style type="text/css">
        code {
            white-space: pre;
            word-break: normal;
            word-wrap: normal;
            background-color: transparent;
            border: none;
        }
    </style>
</head>
<body class="nav-species">
<g:render template="/topMenu" />
<h2>Your Sightings</h2>
<g:if test="${flash.message}">
    <div class="container-fluid">
        <div class="alert alert-info">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            ${raw(flash.message)}
        </div>
    </div>
</g:if>
<div class="row-fluid">
    <div class="span12">
        <g:if test="${sightings}">
            <g:render template="records" />
        </g:if>
        <g:elseif test="${sightings.error}">
            An error occurred: ${sighting.error}
        </g:elseif>
        <g:else>
            No sightings found
        </g:else>
    </div>
</div>
</body>
</html>