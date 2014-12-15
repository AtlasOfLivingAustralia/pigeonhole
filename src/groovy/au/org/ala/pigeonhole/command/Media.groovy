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
package au.org.ala.pigeonhole.command

/**
 * Bean for multimedia data
 *
 * see http://tools.gbif.org/dwca-validator/extension.do?id=http://rs.gbif.org/terms/1.0/Multimedia
 *
 * @author "Nick dos Remedios <Nick.dosRemedios@csiro.au>"
 */
class Media {
    String type = "StillImage" // one of: StillImage, Sound or MovingImage
    String format // mimetype
    String identifier // url
    String title
    String description
    String created // ISO date/time format
    String creator // person who produced the media file
    String license
    String rightsHolder
}
