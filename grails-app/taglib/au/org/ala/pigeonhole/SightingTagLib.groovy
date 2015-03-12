package au.org.ala.pigeonhole

import grails.converters.JSON

import java.text.SimpleDateFormat

class SightingTagLib {
    //static defaultEncodeAs = [taglib:'html']
    //static encodeAsForTags = [tagName: [taglib:'html'], otherTagName: [taglib:'none']]

    static namespace = "si"

    /**
     * Get the hours or minutes part of the input date (or current date)
     *
     * @attr date REQUIRED - java.util.Date
     * @attr part REQUIRED - java.util.Calendar int field (HOUR or MINUTE)
     */
    def getTimeValue = { attrs ->
        def inputDate = attrs.date
        def part = attrs.part

        if (!inputDate) {
            inputDate = new Date()
        }

        def output

        if (part == Calendar.HOUR) {
            SimpleDateFormat hourFormat = new SimpleDateFormat("HH");
            output = hourFormat.format(inputDate)
        } else if (part == Calendar.MINUTE) {
            SimpleDateFormat minFormat = new SimpleDateFormat("mm");
            output = minFormat.format(inputDate)
        }

        out << output
    }

    /**
     * Get a List of tags for both record tags and any higher taxa names
     * and output as a JSON list
     *
     * @attr sighting REQUIRED
     */
    def getTags = { attrs ->
        def sighting = attrs.sighting
        def tags = []
        def fields = ["tags", "kingdom", "family"]

        fields.each {
            if (sighting.has(it)) {
                tags.addAll(sighting.get(it))
            }
        }

        out << (tags as JSON).toString()
    }
}
