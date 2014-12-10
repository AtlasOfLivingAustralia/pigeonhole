package au.org.ala.pigeonhole

class SightingsController {
    def ecodataService, authService

    def index() {
        [user: authService.userDetails(), sightings: ecodataService.getRecentSightings()]
    }

    def user() {
         def user = authService.userDetails()
        [user: user, sightings: ecodataService.getSightingsForUserId(user.userId)]
    }
}
