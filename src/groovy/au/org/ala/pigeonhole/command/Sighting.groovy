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
package au.org.ala.pigeonhole.command

import grails.web.JSONBuilder
import grails.util.Holders
import groovy.util.logging.Log4j
import org.apache.commons.lang.time.DateUtils;

import java.text.DateFormat
import java.text.SimpleDateFormat

/**
 * Command class for the sighting (based on DarwinCore terms)
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
@Log4j
@grails.validation.Validateable
class Sighting {
    String userId
    String guid
    String scientificName
    List<String> tags = [].withDefault { new String() } // taxonomic tags
    String identificationVerificationStatus // identification confidence
    Boolean requireIdentification
    Integer individualCount
    List<Media> multimedia = [].withDefault { new Media() }
    String eventDate // can be date or ISO date with time
    String eventDateNoTime // date only
    String eventDateTime // ISO date + time
    String eventTime // time only
    String timeZoneOffset = (((TimeZone.getDefault().getRawOffset() / 1000) / 60) / 60)
    BigDecimal decimalLatitude
    BigDecimal decimalLongitude
    String geodeticDatum = "WGS84"
    Integer coordinateUncertaintyInMeters
    String georeferenceProtocol
    String locality
    String locationRemark
    String occurrenceRemarks
    String submissionMethod = "website"
    // Properties needed to un-marshall from ecodata
    String occurrenceID
    String dateCreated
    String lastUpdated

    static constraints = {
        scientificName(nullable: true, validator: { val, obj->
            // one of scientificName or tags must be specified
            if ( (!val && !obj.tags)) {
                return 'sighting.sciname.tags'
            }
        })
        eventDateNoTime(blank: false, validator: { val, obj ->
            try {
                Date.parse('dd-MM-yyyy', val)
                return true
            } catch (Exception e) {
                return 'sighting.date.format'
            }
        })
        eventTime(nullable: true,  matches: "^([0-1]?[0-9]|[2][0-3]):([0-5][0-9])(:[0-5][0-9])?\$") // \\d{2}:\\d{2}(:\\d{2})?")
        coordinateUncertaintyInMeters(nullable: true, range: 1..10000)
        decimalLatitude(nullable: true, scale: 8, range: -90..90)
        decimalLongitude(nullable: true,  scale: 8, range: -180..180)
    }

    public String getEventDate() {
        String dt

        if (eventDateTime) {
            dt = eventDateTime
        } else if (eventDateNoTime && eventTime) {
            def date = getIsoDate(eventDateNoTime)
            def time = getValidTime(eventTime)

            if (date && time) {
                log.debug "iso check: ${date}T${time}${timeZoneOffset?:'Z'}"
                Date isoDate = DateUtils.parseDate("${date}T${time}${timeZoneOffset?:'Z'}", [ "yyyy-MM-dd'T'HH:mm:ssZZ" ] as String[])
                DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ssZZ");
                dt = df.format(isoDate)
            }
        } else if (eventDateNoTime) {
            Date isoDate = Date.parse('dd-MM-yyyy', eventDateNoTime)
            DateFormat df = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
            dt = df.format(isoDate) + "${timeZoneOffset ?: 'Z'}";
        }

        dt
    }

    /**
     * Parse and check input date (Australian format DD-MM-YYYY) to
     * iso format (YYYY-MM-DD). If invalid, will return null
     *
     * @param input
     * @return
     */
    private String getIsoDate(String input) throws IllegalArgumentException {
        String output
        def dateBits = input.split('-')

        if (dateBits.length == 3) {
            output = dateBits.reverse().join('-') // Aus date to iso date format
        } else {
            throw new IllegalArgumentException("The date entered, " + input + " is invalid.")
        }

        output
    }

    /**
     * Parse and check input time (String).
     * If invalid, will return null
     *
     * @param input
     * @return
     */
    private String getValidTime(String input) throws IllegalArgumentException  {
        String output
        List timeBits = input.split(':')

        if (timeBits.size() == 2) {
            // assume time without seconds - add zero seconds
            timeBits.add("00")
        }

        if (timeBits.size() == 3) {
            output = timeBits.join(':')
        } else {
            throw new IllegalArgumentException("The time entered, " + input + " is invalid.")
        }

        output
    }

    /**
     * Custom JSON method that allows fields to be excluded.
     * Code from: http://stackoverflow.com/a/5937793/249327
     *
     * @deprecated replaced by the {@link au.org.ala.pigeonhole.marshaller.SightingMarshaller)
     * @param excludes
     * @return JSON (String)
     */
    @Deprecated
    public String asJSON(List excludes = Holders.config.sighting.fields.excludes) {
        def wantedProps = [:]
        log.debug "excludes = ${excludes}"
        //this.properties.each { propName, propValue ->
        Sighting.declaredFields.findAll { !it.synthetic && !excludes.contains(it.name) }.each {
            log.debug "it: ${it.name} = $it || m - ${it.modifiers} || t - ${it.type}"
            def propName = it.name
            def propValue = this.getProperty(propName)
            log.debug "val: ${propValue} || ${propValue.getClass().name}"
            if (propValue instanceof List) {
                log.debug "List found"
                propValue = propValue.findAll {it} // remove empty and null values (and 0 and false)
            }
            if (propValue) {
                wantedProps.put(propName, propValue?:'')
            }
        }
        def builder = new JSONBuilder().build {
            wantedProps
        }
        log.debug "builder: ${builder.toString(true)}"

        builder.toString()
    }
}
