package au.org.ala.pigeonhole

import grails.converters.JSON
import org.apache.tika.mime.MimeType
import org.apache.tika.mime.MimeTypes
import org.springframework.web.multipart.MultipartFile
import org.springframework.web.multipart.MultipartHttpServletRequest
import org.springframework.web.multipart.commons.CommonsMultipartFile

import javax.servlet.http.HttpServletRequest

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
            ]

            return render (output as JSON)
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

        if (grailsApplication.config?.containsKey('imageUploadDir')) {
            File uploadDir = new File(grailsApplication.config.imageUploadDir)

            if (!uploadDir.exists()) {
                uploadDir.mkdirs() ? log.info("Created temp image dir: ${uploadDir.absolutePath}")
                                   : log.warn("Failed to create temp image dir: ${uploadDir.absolutePath}")
            }

            uploaded = new File("${grailsApplication.config.imageUploadDir}/image_${uuid}${ext}")
        } else {
            uploaded = File.createTempFile('grails', "image_${uuid}${ext}")
        }

        if (uploaded) {
            // add some dynamic attributes
            uploaded.metaClass.mimeType = mt.toString()
            uploaded.metaClass.fileName = file.originalFilename
        }

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