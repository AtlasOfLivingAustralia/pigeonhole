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

import grails.web.JSONBuilder
import grails.util.Holders

/**
 * Command class for the sighting (based on DarwinCore terms)
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
@grails.validation.Validateable
class SightingCommand {
    String userId
    String guid
    String scientificName
    Integer individualCount
    String identificationVerificationStatus // identification confidence
    //List<MediaDto> associatedMedia = [].withDefault { new MediaDto() }
    List<String> associatedMedia = [].withDefault { new String() }
    String eventDate // can be date or ISO date with time
    String eventDateNoTime // date only
    String eventDateTime // ISO date + time
    String eventTime // time only
    String timeZoneOffset
    Double decimalLatitude
    Double decimalLongitude
    String geodeticDatum = "WGS84"
    Integer coordinateUncertaintyInMeters
    String georeferenceProtocol
    String locality
    String locationRemark
    String occurrenceRemarks
    String submissionMethod = "website"

    //Date dateCreated
    //Date lastUpdated

    static constraints = {
        scientificName blank: false
        eventDate blank: false
        eventTime blank: false
    }

    public String getEventDate() {
        String dt
        if (eventDateTime) {
            dt = eventDateTime
        } else if (eventDate && eventTime) {
            dt = "${eventDate}T${eventTime}${timeZoneOffset?:'Z'}"
        }
        dt
    }

    /**
     * Custom JSON method that allows fields to be excluded.
     * Code from: http://stackoverflow.com/a/5937793/249327
     *
     * @param excludes
     * @return JSON (String)
     */
    public String asJSON(List excludes = Holders.config.sighting.fields.excludes) {
        def wantedProps = [:]
        log.debug "excludes = ${excludes}"
        //this.properties.each { propName, propValue ->
        SightingCommand.declaredFields.findAll { !it.synthetic && !excludes.contains(it.name) }.each {
            log.debug "it: ${it.name} = $it || m - ${it.modifiers} || t - ${it.type}"
            def propName = it.name
            def propValue = this.getProperty(propName)
            log.debug "val: ${propValue} || ${propValue.getClass().name}"
            //if (!excludes.contains(propName) && propValue) {
                // also exclude empty fields
                //log.debug "propValue type = ${propValue.getClass().name} || ${propValue}"
                wantedProps.put(propName, propValue?:'')
            //}
        }
        def builder = new JSONBuilder().build {
            wantedProps
        }
        log.debug "builder: ${builder.toString(true)}"

        builder.toString()
    }
}
