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

<span id="sightingLinks" style="padding-right: 20px;">
    <g:if test="${params.action == 'user' && params.controller == 'sightings'}">
        <span class="showMySightings">My sightings</span>
    </g:if>
    <g:else>
        <a href="${g.createLink(uri:'/sightings/user')}" class="showMySightings">My sightings</a>
    </g:else>
    |

    <g:if test="${params.action != 'user' && params.controller == 'sightings'}">
        <span class="showMySightings">Recent sightings</span>
    </g:if>
    <g:else>
        <a href="${g.createLink(uri:'/sightings')}" class="showMySightings">Recent sightings</a>
    </g:else>
    &nbsp;&nbsp;
    <a href="${g.createLink(uri:'/')}" class="btn btn-small" style="font-size: 13px;">Submit a sighting</a>

    %{--<a href="http://biocache.ala.org.au/occurrences/search?q=*:*&fq=data_resource_uid:dr364">Occurrence explorer</a>--}%
</span>