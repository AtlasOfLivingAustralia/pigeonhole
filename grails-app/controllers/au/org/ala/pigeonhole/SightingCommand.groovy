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
    List<MediaDto> associatedMedia = [].withDefault { new MediaDto() }
    String date
    String time
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
        date blank: false
        time blank: false
    }
    public String getEventDate() {
        String dt
        if (date && time) {
            dt = "${date}T${time}${timeZoneOffset?:'Z'}"
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
    public String asJSON(List excludes = []) {
        if (!excludes) {
            excludes = ['errors', 'eventDate', 'timeZoneOffset', 'class', 'constraints']
        }
        def wantedProps = [:]
        this.properties.each { propName, propValue ->
            if (!excludes.contains(propName) && propValue) {
                // also exclude empty fields
                wantedProps.put(propName, propValue?:'')
            }
        }
        def builder = new JSONBuilder().build {
            wantedProps.each {

            }
        }
        log.debug "builder: ${builder.toString(true)}"

        builder.toString()
    }
}
