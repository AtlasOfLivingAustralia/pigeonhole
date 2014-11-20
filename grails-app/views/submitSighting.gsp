<%--
  Created by IntelliJ IDEA.
  User: dos009@csiro.au
  Date: 6/11/2014
  Time: 4:35 PM
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta name="layout" content="main"/>
    <title>Submit a sighting</title>
    <r:require modules="fileuploads, exif"/>
    <r:script>
        $(function () {
            console.log("jquery check", $('#species').text());
            %{--$('#fileupload').fileupload({--}%
                %{--url: '${createLink(uri:"/ajaxUpload/upload")}',--}%
                %{--sequentialUploads: true--}%
            %{--});--}%
            // upload code taken from http://blueimp.github.io/jQuery-File-Upload/basic-plus.html
            var url = '${createLink(uri:"/ajaxUpload/upload")}',
                uploadButton = $('<button/>')
                    .addClass('btn btn-primary')
                    .prop('disabled', true)
                    .text('Processing...')
                    .on('click', function () {
                        var $this = $(this),
                            data = $this.data();
                        $this
                            .off('click')
                            .text('Abort')
                            .on('click', function () {
                                $this.remove();
                                data.abort();
                            });
                        data.submit().always(function () {
                            $this.remove();
                        });
                    });
            $('#fileupload').fileupload({
                url: url,
                dataType: 'json',
                autoUpload: false,
                acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
                maxFileSize: 5000000, // 5 MB
                // Enable image resizing, except for Android and Opera,
                // which actually support image resizing, but fail to
                // send Blob objects via XHR requests:
                disableImageResize: /Android(?!.*Chrome)|Opera/
                    .test(window.navigator.userAgent),
                previewMaxWidth: 100,
                previewMaxHeight: 100,
                previewCrop: true
            }).on('fileuploadadd', function (e, data) {
                data.context = $('<div/>').appendTo('#files');
                $.each(data.files, function (index, file) {
                    var node = $('<p/>')
                            .append($('<span/>').text(file.name));
                    if (!index) {
                        node
                            .append('<br>')
                            .append(uploadButton.clone(true).data(data));
                    }
                    node.appendTo(data.context);
                });
            }).on('fileuploadprocessalways', function (e, data) {
                var index = data.index,
                    file = data.files[index],
                    node = $(data.context.children()[index]);
                if (file.preview) {
                    node
                        .prepend('<br>')
                        .prepend(file.preview);
                }
                if (file.error) {
                    node
                        .append('<br>')
                        .append($('<span class="text-danger"/>').text(file.error));
                }
                if (index + 1 === data.files.length) {
                    data.context.find('button')
                        .text('Upload')
                        .prop('disabled', !!data.files.error);
                }
            }).on('fileuploadprogressall', function (e, data) {
                var progress = parseInt(data.loaded / data.total * 100, 10);
                $('#progress .progress-bar').css(
                    'width',
                    progress + '%'
                );
            }).on('fileuploaddone', function (e, data) {
                //$.each(data, function (index, file) {
                    if (data.url) {
                        var link = $('<a>')
                            .attr('target', '_blank')
                            .prop('href', data.url);
                        $(data)
                            .wrap(link);
                    } else if (data.error) {
                        var error = $('<span class="text-danger"/>').text(data.error);
                        $(data.context.children()[index])
                            .append('<br>')
                            .append(error);
                    }
                //});
            }).on('fileuploadfail', function (e, data) {
                //$.each(data.files, function (index) {
                    var error = $('<span class="text-danger"/>').text('File upload failed.');
                    $(data)
                        .append('<br>')
                        .append(error);
                //});
            }).prop('disabled', !$.support.fileInput)
                .parent().addClass($.support.fileInput ? undefined : 'disabled');
        });
    </r:script>
    <style type="text/css">

        .fileinput-button {
            position: relative;
            overflow: hidden;
        }
        .fileinput-button input {
            position: absolute;
            top: 0;
            right: 0;
            margin: 0;
            opacity: 0;
            -ms-filter: 'alpha(opacity=0)';
            font-size: 200px;
            direction: ltr;
            cursor: pointer;
        }

        /* Fixes for IE < 8 */
        @media screen\9 {
            .fileinput-button input {
                filter: alpha(opacity=0);
                font-size: 100%;
                height: 100%;
            }
        }

    </style>
</head>
<body class="nav-species">
<h2>Submit a Sighting</h2>
<div class="bs-docs-example" id="species" data-content="Species">
    what is it?
</div>

<div class="bs-docs-example" id="media" data-content="Media">
    <p>Optional</p>
    <div class="" id="">Drag files here, or</div>
    %{--<span class="btn btn-success fileinput-button">--}%
        %{--<i class="glyphicon glyphicon-plus"></i>--}%
        %{--<span>Add files...</span>--}%
        %{--<!-- The file input field used as target for the file upload widget -->--}%
        %{--<input id="fileupload" type="file" name="files[]" multiple directory webkitdirectory mozdirectory>--}%
    %{--</span>--}%
    <!-- The fileinput-button span is used to style the file input field as button -->
    <span class="btn btn-success fileinput-button">
        <i class="glyphicon glyphicon-plus"></i>
        <span>Add files...</span>
        <!-- The file input field used as target for the file upload widget -->
        <input id="fileupload" type="file" name="files[]" multiple>
    </span>
    <br>
    <br>
    <!-- The global progress bar -->
    <div id="progress" class="progress">
        <div class="progress-bar progress-bar-success"></div>
    </div>
    <!-- The container for the uploaded files -->
    <div id="files" class="files"></div>
</div>

<div class="bs-docs-example" id="location" data-content="Location">
    <p>Where </p>
</div>

<div class="bs-docs-example" id="details" data-content="Details">
    <p></p>
</div>

<form id="myform">
    <input type="file" id="file" /> </br>
    <label>Camera Model</label>
    <input type="text" name="cameraModel" id="cameraModel" /> </br>

    <label>Aperture</label>
    <input type="text" name="aperture" id="aperture" /> </br>

</form>
<script>
    var someCallback = function(exifObject) {
        $('#cameraModel').val(exifObject.Model);
        $('#aperture').val(exifObject.FNumber);
        // Uncomment the line below to examine the
        // EXIF object in console to read other values
        console.log(exifObject);
    }
    try {
        $('#file').change(function() {
            $(this).fileExif(someCallback);
        });
    }
    catch (e) {
        alert(e);
    }
</script>

</body>
</html>