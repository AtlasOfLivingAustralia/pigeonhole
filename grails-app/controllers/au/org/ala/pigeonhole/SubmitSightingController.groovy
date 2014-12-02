/*
 * Copyright (C) 2014 Atlas of Living Australia
 * All Rights Reserved.
 *
 * The contents of this file are subject to the Mozilla Public
 * License Version 1.1 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a copy of
 * the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS
 * IS" basis, WITHOUT WARRANTY OF ANY KIND, either express or
 * implied. See the License for the specific language governing
 * rights and limitations under the License.
 */

package au.org.ala.pigeonhole

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject

class SubmitSightingController {
    def httpWebService, authService, ecodataService, bieService

    def index(String id) {
        //def sighting
        [
                taxon: getTaxon(id),
                //sighting: sighting?:new SightingCommand(),
                coordinateSources: grailsApplication.config.coordinates.sources,
                speciesGroupsMap: bieService.getSpeciesGroupsMap(),
                user:authService.userDetails()
        ]
    }

    def edit(String id) {
        SightingCommand sighting = ecodataService.getSighting(id)
        render view: "index", mode: [taxon: getTaxon(sighting.guid), sighting: sighting, coordinateSources: grailsApplication.config.coordinates.sources, user:authService.userDetails()]
    }

    def upload(SightingCommand sighting) {
        //log.debug "upload sighting: ${sighting as JSON}"
        def userId = authService.userId ?: 99999
        def debug = true;

        sighting.userId = userId
        JSONObject result

        if (!sighting.validate()) {
            sighting.errors.allErrors.each {
                log.warn "upload validation error: ${it}"
            }
            log.debug "chaining - sighting = ${sighting}"
            // chain action: "index", id: "${sighting.guid}", model: [sighting: sighting, taxon: getTaxon(sighting.guid), coordinateSources: grailsApplication.config.coordinates.sources, user:authService.userDetails()]
            chain action: "index", id: "${sighting.guid}", model: [sighting: sighting]
        } else if (debug) {
            render sighting as JSON
        } else {
            result = ecodataService.submitSighting(sighting)
            render(status: result.status, text: result as JSON, contentType: "application/json")
        }
    }

    private JSONObject getTaxon(guid) {
        JSONObject taxon

        if (guid) {
            taxon = httpWebService.getJson("${grailsApplication.config.bie.baseUrl}/ws/species/shortProfile/${guid}.json")
            if (taxon.has('scientificName')) {
                taxon.guid = guid // not provided by /ws/species/shortProfile
            }
        }

        taxon
    }
}
