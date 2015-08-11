package au.org.ala.pigeonhole

import grails.plugin.cache.Cacheable
import org.codehaus.groovy.grails.web.json.JSONArray

class BieService {
    def grailsApplication, httpWebService

    @Cacheable('longTermCache')
    def Map getSpeciesGroupsMap() {
        try {
            JSONArray resp = httpWebService.getJson("${grailsApplication.config.bie.baseUrl}/subgroups.json")
            Map groupsMap = [:]
            resp.each {
                groupsMap.put(it.speciesGroup, it.taxa)
            }
            groupsMap
        } catch(Exception e){
            log.error("Problem retrieving species group information: " + e.getMessage(), e)    
            [:]
        }
    }
}
