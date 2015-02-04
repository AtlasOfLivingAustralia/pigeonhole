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

import au.org.ala.pigeonhole.command.Sighting
import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject

class SubmitSightingController {
    def httpWebService, authService, ecodataService, bieService

    def index(String id) {
        log.debug "ID = ${id} || ${params}"
        [
                taxon: getTaxon(id),
                coordinateSources: grailsApplication.config.coordinates.sources,
                speciesGroupsMap: bieService.getSpeciesGroupsMap(),
                user:authService.userDetails(),
                //bookmarks: ecodataService.getBookmarkLocationsForUser(authService.userId) // Map
        ]
    }

    def edit(String id) {
        log.debug "id = ${id} || ${params}"
        Sighting sighting = ecodataService.getSighting(id)

        if (sighting.error) {
            //flash.message = sighting.error
            render view: "index", model: [
                    sighting: sighting,
                    user:authService.userDetails()
            ]
        } else {
            log.debug "EDIT - guid = ${sighting.guid} || getTaxon(sighting.guid)"
            render view: "index", model: [
                    sighting: sighting,
                    taxon: getTaxon(sighting.guid),
                    coordinateSources: grailsApplication.config.coordinates.sources,
                    speciesGroupsMap: bieService.getSpeciesGroupsMap(),
                    user:authService.userDetails()
            ]
        }
    }

    def upload(Sighting sighting) {
        log.debug "upload params: ${params as JSON}"
        //log.debug "upload sighting: ${sighting as JSON}"
        def userId = authService.userId ?: 99999
        def debug = grailsApplication.config.submit.debug;

        sighting.userId = userId
        JSONObject result

        if (!sighting.validate()) {
            sighting.errors.allErrors.each {
                log.warn "upload validation error: ${it}"
            }
            log.debug "chaining - sighting = ${sighting}"
            flash.message = "There was a problem with one or more fields, please fix these errors (in red)"
            // chain action: "index", id: "${sighting.guid}", model: [sighting: sighting, taxon: getTaxon(sighting.guid), coordinateSources: grailsApplication.config.coordinates.sources, user:authService.userDetails()]
            chain action: "index", id: "${sighting.guid?:''}", model: [sighting: sighting]
        } else if (debug) {
            // render sighting.asJSON()
            // respond sighting, [formats:['json', 'xml']]
            //render sighting as JSON
            String sj = (sighting as JSON).toString(true)
            flash.message = "You sighting was successfully (dummy) submitted." +
                    "<br><code>${sj}</code>"
            redirect(uri:'/sightings/user')
        } else {
            result = ecodataService.submitSighting(sighting)
            //render(status: result.status, text: result as JSON, contentType: "application/json")
            if (result.error) {
                // ecodata returned an error
                flash.message = "There was a problem submitting your sighting, please try again. If this problem persists, please send an email to support@ala.org.au.<br>"
                        + result.error
                chain action: "index", id: "${sighting.guid?:''}", model: [sighting: sighting]
            } else {
                flash.message = "You sighting was successfully submitted."
                redirect(uri:'/sightings/user')
            }
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
