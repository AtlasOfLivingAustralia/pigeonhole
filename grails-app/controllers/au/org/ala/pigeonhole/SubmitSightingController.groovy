package au.org.ala.pigeonhole

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONObject

class SubmitSightingController {
    def httpWebService

    def index(String lsid) {
        JSONObject taxon

        if (lsid) {
            taxon = httpWebService.getJson("${grailsApplication.config.bie.baseUrl}/ws/species/shortProfile/${lsid}.json")
            log.debug "taxon class = ${taxon.getClass().name}"
            if (taxon.has('scientificName')) {
                taxon.guid = lsid
            }
            log.debug "taxon = ${taxon}"
        }

        [taxon: taxon, coordinateSources: grailsApplication.config.coordinates.sources]
    }

    def upload(SightingCommand sighting) {
        log.debug "upload sighting: ${sighting as JSON}"
        render sighting as JSON
    }
}
