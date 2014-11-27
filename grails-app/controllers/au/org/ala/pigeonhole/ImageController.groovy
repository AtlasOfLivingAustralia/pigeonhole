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
