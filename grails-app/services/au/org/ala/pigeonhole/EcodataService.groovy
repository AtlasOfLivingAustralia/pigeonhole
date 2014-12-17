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
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONObject
import org.codehaus.groovy.runtime.typehandling.GroovyCastException

class EcodataService {
    def grailsApplication, httpWebService

    Sighting getSighting(String id) {
        Sighting sc

        try {
            sc = new Sighting(httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record/${id}"))
        } catch (GroovyCastException gce) {
            log.error gce, gce
            sc.errors[0] = gce.message
        }

        sc
    }

    Map submitSighting(Sighting sightingCommand) {
        // TODO implement webservice POST
        def url = grailsApplication.config.ecodata.baseUrl + "/record"
        def json = sightingCommand as JSON
        def result = doJsonPost(url, json)
        log.debug "ecodata result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        [status:result.status?:200, text: result.error?:result]
    }

    def getSightingsForUserId(String userId) {
        JSONObject res = httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record/user/${userId}")
        JSONArray sightings

        if (res?.records) {
            sightings = res.records
        }

        sightings
    }

    def getRecentSightings() {
        //log.debug "records = " + httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record")
        httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record")
    }

    def doJsonPost(String url, String postBody) {
        //println "post = " + postBody
        log.debug "url = ${url} "
        log.debug "postBody = ${postBody} "
        def http = new HTTPBuilder(url)
        http.request( groovyx.net.http.Method.POST, groovyx.net.http.ContentType.JSON ) {
            body = postBody
            requestContentType = ContentType.JSON

            response.success = { resp, json ->
                log.debug "json = " + json
                log.debug "resp = ${resp}"
                log.debug "json is a ${json.getClass().name}"
                return json
            }

            response.failure = { resp ->
                def error = [error: "Unexpected error: ${resp.statusLine.statusCode} : ${resp.statusLine.reasonPhrase}", status: resp.statusLine.statusCode]
                log.error "Oops: " + error.error
                return error
            }
        }
    }
}
