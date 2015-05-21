package au.org.ala.pigeonhole

import grails.converters.JSON

class SightingsController {

    def ecodataService, authService
    def sightingValidationService

    def index() {
        [user: authService.userDetails()?:[:], sightings: ecodataService.getRecentSightings(params), pageHeading: "Recent sightings"]
    }

    def validate(){
        def requestJson = request.JSON
        log.debug("Checking: ${requestJson.scientificName} with ${requestJson.decimalLatitude}, ${requestJson.decimalLongitude}")
        if(requestJson.scientificName && requestJson.decimalLatitude && requestJson.decimalLongitude){
            def result = sightingValidationService.validate(requestJson.scientificName, requestJson.decimalLatitude, requestJson.decimalLongitude)
            render (result as JSON)
        } else {
            response.sendError(400, "Service requires a JSON payload with scientificName, decimalLatitude and decimalLongitude properties.")
        }
    }

    def validateTest1(){
        def result = sightingValidationService.validate("Diodon holocanthus", -18.4,  144.1)
        render (result as JSON)
    }

    def validateTest2(){
        def result = sightingValidationService.validate("Macropus rufus", -37.1,  149.1)
        render (result as JSON)
    }

    def validateTest3(){
        def result = sightingValidationService.validate("Calyptorhynchus latirostris", -37.1,  149.1)
        render (result as JSON)
    }

    def validateTest4(){
        def result = sightingValidationService.validate("Carcharodon carcharias", -37.1,  145.1)
        render (result as JSON)
    }

    def validateTest5(){
        def result = sightingValidationService.validate("Wollemia nobilis", -37.1,  149.1)
        render (result as JSON)
    }


    def user(String id) {
        def user = authService.userDetails()
        String heading =  "My sightings"

        if (id) {
            user = authService.getUserForUserId(id)

            if (user) {
                def name = user.displayName
                heading =  "${name}'${(name.endsWith('s')) ? '' : 's'} sightings"
            } else {
                heading =  "User sightings"
                flash.errorMessage = "Error: Could not find user with ID ${id}"
            }
        }

        render(view:"index", model:[user: user, sightings: ecodataService.getSightingsForUserId(user?.userId, params), pageHeading: heading])
    }

    def delete(String id) {
        log.debug "DEL id = ${id}"
        def user = authService.userDetails()
        String recordUserId = ecodataService.getUserIdForSightingId(id)


        if (authService.userInRole("${grailsApplication.config.security.cas.adminRole}") || user?.userId == recordUserId) {
            def result = ecodataService.deleteSighting(id)
            log.debug "result = ${result}"

            if (result == 200) {
                flash.message = "Record was successfully deleted"
            } else {
                flash.message = "An error occurred. Record was not deleted"
            }
        } else {
            flash.message = "You do not have permission to delete record ${id}"
        }
        
        redirect(uri: request.getHeader('referer') )
    }
}
