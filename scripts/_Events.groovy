/*
 * Copyright (C) 2016 Atlas of Living Australia
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

import grails.util.Environment
import org.apache.catalina.connector.*
import org.apache.catalina.startup.Tomcat

eventConfigureTomcat = { Tomcat tomcat ->
    if (Environment.current == Environment.DEVELOPMENT) {
        println "### Enabling AJP/1.3 connector"
        def ajpConnector = new Connector("org.apache.coyote.ajp.AjpProtocol")
        ajpConnector.port = 8009
        ajpConnector.protocol = 'AJP/1.3'
        ajpConnector.redirectPort = 8443
        ajpConnector.enableLookups = false
        ajpConnector.setProperty('redirectPort', '443')
        ajpConnector.setProperty('protocol', 'AJP/1.3')
        ajpConnector.setProperty('enableLookups', 'false')
        tomcat.service.addConnector ajpConnector
        println ajpConnector.toString()
        println "### Ending enabling AJP connector"
    }
}