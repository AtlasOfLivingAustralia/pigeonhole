package au.org.ala.pigeonhole

import au.org.ala.pigeonhole.command.Sighting

class SightingsController {
    def ecodataService, authService

    def index() {
        [user: authService.userDetails(), sightings: ecodataService.getRecentSightings(params), pageHeading: "Recent sightings"]
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


        if (authService.userInRole("ROLE_ADMIN") || user?.userId == recordUserId) {
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

        render(view: "index", model:[user: user, sightings: ecodataService.getSightingsForUserId(user?.userId, params), pageHeading: "Your Sightings"])
    }
}
