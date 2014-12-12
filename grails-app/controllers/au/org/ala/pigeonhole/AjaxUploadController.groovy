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

/**
 * Server side code for the jQuery fileupload plugin, which performs an AJAX
 * file upload in the background
 */
class AjaxUploadController {
    def imageService

    def upload = {
        try {

            File uploaded = imageService.createTemporaryFile(request.getFile("files[]"))
            InputStream inputStream = imageService.selectInputStream(request)
            imageService.uploadFile(inputStream, uploaded)
            File thumbFile = imageService.generateThumbnail(uploaded)

            def output = [
                    success:true,
                    mimeType: uploaded.mimeType, // metaClass attr
                    filename: uploaded.fileName, // metaClass attr
                    url: "${g.createLink(uri:"/uploads/${uploaded.name}", absolute:true)}",
                    thumbnailUrl: "${g.createLink(uri:"/uploads/${thumbFile.name}", absolute:true)}",
                    exif: imageService.getExifForFile(uploaded)
                    //url: "http://fielddata.ala.org.au/media/5477b4b53dff0a1e61d47514/0_P1010659.JPG" // TODO remove hardcoded value!!!
            ]

            return render (status: 200, text: output as JSON)
        } catch (Exception e) {
            log.error("Failed to upload file.", e)
            return render(status: 302, text: [success:false, error: e.message] as JSON)
        }
    }

}