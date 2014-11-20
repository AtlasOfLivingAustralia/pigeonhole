package au.org.ala.pigeonhole

import org.apache.commons.io.FilenameUtils

import javax.activation.MimetypesFileTypeMap

class ImageController {

    def index(String file) {
        log.debug "file = ${file} || params.file = ${params.file}"
        String fileName = "${grailsApplication.config.imageUploadDir}${file}"
        File imageFile = new File(fileName)

        if (imageFile.exists()) {
            MimetypesFileTypeMap mimeTypesMap = new MimetypesFileTypeMap()
            response.contentType = mimeTypesMap.getContentType(imageFile)
            response.outputStream << imageFile.bytes
            response.outputStream.flush()
        } else {
            render (status: 404, text: "No file found: ${fileName}")
        }
    }
}
