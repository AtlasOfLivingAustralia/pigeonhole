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

import au.org.ala.pigeonhole.command.Bookmark
import au.org.ala.pigeonhole.command.Sighting
import grails.converters.JSON
import groovyx.net.http.ContentType
import groovyx.net.http.HTTPBuilder
import org.apache.commons.lang.time.DateUtils
import org.codehaus.groovy.grails.web.json.JSONArray
import org.codehaus.groovy.grails.web.json.JSONElement
import org.codehaus.groovy.grails.web.json.JSONObject
import org.codehaus.groovy.grails.web.servlet.mvc.GrailsParameterMap
import org.joda.time.DateTime
import org.joda.time.format.DateTimeFormat
import org.joda.time.format.DateTimeFormatter
import org.joda.time.format.ISODateTimeFormat

import java.text.DateFormat
import java.text.SimpleDateFormat;

class EcodataService {
    def grailsApplication, httpWebService

    Sighting getSighting(String id) {
        Sighting sc = new Sighting()

        def json = httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record/${id}")

        if (json instanceof JSONObject && json.has("error")) {
            // WS failed
            sc.error = json.error
        } else if (json instanceof JSONObject) {
            json = fixJsonValues(json)
            try {
                sc = new Sighting(json)
            } catch (Exception e) {
                log.error "Couldn't unmarshall JSON - " + e.message, e
                sc.error = "Error: sighting could not be loaded - ${e.message}"
            }
        } else {
            log.error "Unexpected error: ${json}"
            sc.error = "Unexpected error: ${json}"
        }

        sc
    }

    /**
     * Non JSON marshalling method for getting userId for a record id
     * Needed for older records which can't be marshalled into the Sighting Obj
     *
     * @param id
     * @return
     */
    String getUserIdForSightingId(String id) {
        def json = httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record/${id}")
        String userId = ""

        if (json instanceof JSONObject && json.has("userId")) {
            userId = json.userId
        }

        userId
    }

    Map submitSighting(Sighting sightingCommand) {
        // TODO implement webservice POST
        def url = grailsApplication.config.ecodata.baseUrl + "/record"

        if (sightingCommand.occurrenceID) {
            // must be an edit if occurrenceID is present
            url += "/${sightingCommand.occurrenceID}"
        }

        def json = sightingCommand as JSON
        def result = doJsonPost(url, json.toString())
        log.debug "ecodata result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        def returnMap = [status: result.status?:200]

        if (result.error) {
            returnMap.error = result.error
        } else {
            returnMap.text = result
        }

        returnMap
    }

    private String getQueryStringForParams(GrailsParameterMap params, Boolean convertKeys) {
        params.remove("controller")
        params.remove("action")
        params.remove("format")
        String queryString = params.toQueryString()

        if (convertKeys) {
            // convert Grails pagination params to SOLR params
            queryString = queryString.replaceAll("max", "pageSize")
            queryString = queryString.replaceAll("offset", "start")
        }

        log.debug "params string = ${queryString}"

        queryString
    }

    def deleteSighting(String id) {
        doDelete("${grailsApplication.config.ecodata.baseUrl}/record/${id}") // returns statusCode 200|500
    }

    def getSightingsForUserId(String userId, GrailsParameterMap params) {
        httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record/user/${userId}" + getQueryStringForParams(params, true))
    }

    def getRecentSightings(GrailsParameterMap params) {
        //log.debug "records = " + httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record")
        JSONObject sightings = new JSONObject()
        def result = httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/record" + getQueryStringForParams(params, true))

        if (result instanceof JSONArray) {
            sightings.put("records", result)
        } else if (result instanceof JSONObject) {
            sightings = result
        }

        sightings
    }

    def getBookmarkLocationsForUser(String userId) {
        def bookmarks = []
        JSONElement results = httpWebService.getJson("${grailsApplication.config.ecodata.baseUrl}/location/user/$userId?pageSize=20")

        if (results.hasProperty('error')) {
            return [error: results.error]
        } else {
            results.each {
                bookmarks.add(new Bookmark(it))
            }
        }

        bookmarks
    }

    def addBookmarkLocation(JSONObject bookmarkLocation) {
        def url = grailsApplication.config.ecodata.baseUrl + "/location/"
        def result = doJsonPost(url, bookmarkLocation.toString())
        log.debug "ecodata post bookmark result = ${result}"
        // if error return Map below
        // else return Map key/values as JSON
        [status:result.status?:200, message: (result.error?:result)]
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

    def doDelete(String url) {
        log.debug "DELETE url = ${url}"
        def conn = new URL(url).openConnection()
        try {
            conn.setRequestMethod("DELETE")
            return conn.getResponseCode()
        } catch(Exception e){
            log.error e.message
            return 500
        } finally {
            if (conn != null){
                conn.disconnect()
            }
        }
    }

    /**
     * Remove pesky JSONObject.NULL values from JSON, which cause GroovyCastException errors
     * during Object binding.
     *
     * @param json
     * @return
     */
    private fixJsonValues(JSONObject json) {
        JSONObject jsonCopy = new JSONObject(json)
        json.each {
            if (it.value == JSONObject.NULL) {
                jsonCopy.remove(it.key)
            } else if (it.key == 'eventDate') {
                try {
                    DateTimeFormatter format = DateTimeFormat.forPattern("yyyy-MM-dd'T'HH:mm:ssZ");
                    DateTime dateTime = format.withOffsetParsed().parseDateTime(it.value)
                    Date date = dateTime.toDate();
                    jsonCopy.eventDate = date
                } catch (Exception e) {
                    log.warn "Error parsing iso date: ${e.message}", e
                }
            }
        }

        log.debug "jsonCopy = ${jsonCopy.toString(2)}"

        jsonCopy
    }
}
