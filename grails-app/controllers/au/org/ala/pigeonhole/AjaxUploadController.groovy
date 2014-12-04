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

import grails.converters.JSON
import org.apache.tika.mime.MimeType
import org.apache.tika.mime.MimeTypes
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.commons.CommonsMultipartFile

import javax.servlet.http.HttpServletRequest

/**
 * Server side code for the jQuery fileupload plugin, which performs an AJAX
 * file upload in the background
 */
class AjaxUploadController {

    def upload = {
        try {

            File uploaded = createTemporaryFile()
            InputStream inputStream = selectInputStream(request)
            uploadFile(inputStream, uploaded)

            def output = [
                    success:true,
                    mimeType: uploaded.mimeType, // metaClass attr
                    filename: uploaded.fileName, // metaClass attr
                    url: "${g.createLink(uri:"/uploads/${uploaded.name}", absolute:true)}"
                    //url: "http://fielddata.ala.org.au/media/5477b4b53dff0a1e61d47514/0_P1010659.JPG" // TODO remove hardcoded value!!!
            ]

            return render (status: 200, text: output as JSON)
        } catch (Exception e) {
            log.error("Failed to upload file.", e)
            return render(status: 302, text: [success:false, error: e.message] as JSON)
        }
    }

    private InputStream selectInputStream(HttpServletRequest request) {
        if (request instanceof MultipartHttpServletRequest) {
            MultipartFile uploadedFile = ((MultipartHttpServletRequest) request).getFile('files[]')
            return uploadedFile.inputStream
        }
        return request.inputStream
    }

    /**
     * Generate a File (filepath really) for the image upload (not yet created)
     *
     * @return
     */
    private File createTemporaryFile() {
        File uploaded
        String uuid = UUID.randomUUID().toString() // unique temp image file name
        //String mimeType = request.contentType
        CommonsMultipartFile file = request.getFile("files[]")
        log.debug "file type = ${file.contentType} || file class = ${file.getClass().name}"

        //String ext = MIMETypeUtil.fileExtensionForMIMEType(mimeType)
        MimeTypes allTypes = MimeTypes.getDefaultMimeTypes()
        MimeType mt = allTypes.forName(file.contentType)
        String ext = mt.getExtension()

        if (grailsApplication.config?.containsKey('media')) {
            File uploadDir = new File("${grailsApplication.config.media.uploadDir}")
            def filename = file.originalFilename

            if (!uploadDir.exists()) {
                uploadDir.mkdirs() ? log.info("Created temp image dir: ${uploadDir.absolutePath}")
                                   : log.error("Failed to create temp image dir: ${uploadDir.absolutePath} - PLEASE FIX")
            }

            //uploaded = new File("${grailsApplication.config.imageUploadDir}/image_${uuid}${ext}")
            uploaded = new File("${grailsApplication.config.media.uploadDir}/${filename}")
        } else {
            //uploaded = File.createTempFile('grails', "image_${uuid}${ext}")
            uploaded = File.createTempFile('grails', "${filename}")
        }

        if (uploaded) {
            // add some dynamic attributes
            uploaded.metaClass.mimeType = mt.toString()
            uploaded.metaClass.fileName = file.originalFilename
        }

        log.debug "uploaded = ${uploaded.absolutePath}"

        return uploaded
    }

    private void uploadFile(InputStream inputStream, File file) {

        try {
            file << inputStream
        } catch (Exception e) {
            throw new Exception(e)
        }

    }

}