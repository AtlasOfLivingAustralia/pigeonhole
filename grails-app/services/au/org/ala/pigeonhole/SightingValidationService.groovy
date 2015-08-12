package au.org.ala.pigeonhole

import grails.converters.JSON
import org.codehaus.groovy.grails.web.json.JSONElement

/**
 * A service for validating sighting information by querying and combining existing ALA services.
 */
class SightingValidationService {

    static transactional = false

    def webserviceService

    def grailsApplication

    /** See http://biocache.ala.org.au/ws/assertions/codes for more details */
    def final static HABITAT_MISMATCH_ASSERTION_CODE = 19

    /** Biocache QA status codes are  0=failed, 1=passed, 2=unchecked,  */
    def final static QA_STATUS_CODE_FAILED = 0

    /**
     * Performs a set of validation checks on a record.
     *
     * @param name
     * @param lat
     * @param lon
     * @return
     */
    def validate(name, lat, lon){

        try {
            def biocacheResponse = webserviceService.doPost(grailsApplication.config.biocache.validation.url, [
                    scientificName  : name,
                    decimalLatitude : lat,
                    decimalLongitude: lon
            ])

            def payload = biocacheResponse.resp

            def scientificName = payload.values.find { it.name == "scientificName" }?.processed
            def taxonConceptID = payload.values.find { it.name == "taxonConceptID" }?.processed
            def decimalLatitude = payload.values.find { it.name == "decimalLatitude" }?.processed
            def decimalLongitude = payload.values.find { it.name == "decimalLongitude" }?.processed
            def dataGeneralizations = payload.values.find { it.name == "dataGeneralizations" }?.processed
            def originalDecimalLatitude = payload.values.find { it.name == "decimalLatitude" }?.raw
            def originalDecimalLongitude = payload.values.find { it.name == "decimalLongitude" }?.raw

            def globalConservation = getStatus(payload, "globalConservation")
            def countryConservation = getStatus(payload, "countryConservation")
            def stateProvinceConservation = getStatus(payload, "stateProvinceConservation")

            //habitat mismatch
            def habitatMismatch = false
            def habitatMismatchMessage = ""
            def habitatCheck = payload.assertions.find { it.code == HABITAT_MISMATCH_ASSERTION_CODE }
            if (habitatCheck) {
                habitatMismatch = habitatCheck.qaStatus == 0 ? true : false
                habitatMismatchMessage = habitatCheck.comment
            }

            //create a simple map of the other tests that have been ran
            def tests = [:]
            payload.assertions.each {
                tests.put(it.name, it.qaStatus == QA_STATUS_CODE_FAILED ? false : true)
            }

            //do an intersect with the expert distribution if one is available
            def expertOutlierResponse = {
                try {
                    webserviceService.doPostWithParams(
                            grailsApplication.config.layers.service.url + "/distribution/outliers/" + taxonConceptID,
                            ["pointsJson": (["occurrence": [decimalLatitude: lat, decimalLongitude: lon]] as JSON).toString()]
                    )
                } catch (Exception e){
                    //this service doesn't respond well to taxon not found lookups
                    log.warn("Unable to lookup expert distribution for " + taxonConceptID)
                    null
                }
            }.call()

            def outlierForExpertDistribution = false
            def distanceFromExpertDistributionInMetres = ""
            def imageOfExpertDistribution = ""

            if (expertOutlierResponse && expertOutlierResponse.resp) {
                if (expertOutlierResponse.resp."occurrence") {
                    outlierForExpertDistribution = true
                    distanceFromExpertDistributionInMetres = expertOutlierResponse.resp."occurrence"
                }

                def expertDistro = webserviceService.getJson(grailsApplication.config.layers.service.url + "/distribution/map/" + URLEncoder.encode(scientificName, "UTF-8"))
                if (expertDistro.url) {
                    imageOfExpertDistribution = expertDistro.url
                }
            }

            return [
                    taxonConceptID                        : taxonConceptID,
                    scientificName                        : scientificName,
                    decimalLatitude                       : decimalLatitude,
                    decimalLongitude                      : decimalLongitude,
                    sensitive                             : payload.sensitive ?: false,
                    dataGeneralizations                   : dataGeneralizations,
                    originalDecimalLatitude               : originalDecimalLatitude,
                    originalDecimalLongitude              : originalDecimalLongitude,
                    outlierForExpertDistribution          : outlierForExpertDistribution,
                    distanceFromExpertDistributionInMetres: distanceFromExpertDistributionInMetres,
                    imageOfExpertDistribution             : imageOfExpertDistribution,
                    conservationStatus                    : [
                            stateProvince: stateProvinceConservation,
                            country      : countryConservation,
                            global       : globalConservation
                    ],
                    habitatMismatch                       : habitatMismatch,
                    habitatMismatchDetail                 : habitatMismatchMessage,
                    otherTests                            : tests
            ]
        } catch (Exception e){
            //this service is a best effort currently, avoid breaking anything upstream
            log.error("Validation lookup failed: " + e.getMessage())
            return [:]
        }
    }

    private def getStatus(JSONElement payload, statusName) {
        def value = payload.values.find { it.name == statusName }?.processed
        if(value){
            def values = value.split(",")
            values.first()
        } else {
            null
        }
    }
}
