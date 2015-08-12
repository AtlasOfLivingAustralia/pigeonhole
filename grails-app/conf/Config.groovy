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
/******************************************************************************\
 *  CONFIG MANAGEMENT
 \******************************************************************************/
def appName = 'pigeonhole'
def ENV_NAME = "${appName.toUpperCase()}_CONFIG"
default_config = "/data/${appName}/config/${appName}-config.properties"
if(!grails.config.locations || !(grails.config.locations instanceof List)) {
    grails.config.locations = []
}
if(System.getenv(ENV_NAME) && new File(System.getenv(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified in environment: " + System.getenv(ENV_NAME);
    grails.config.locations.add "file:" + System.getenv(ENV_NAME)
} else if(System.getProperty(ENV_NAME) && new File(System.getProperty(ENV_NAME)).exists()) {
    println "[${appName}] Including configuration file specified on command line: " + System.getProperty(ENV_NAME);
    grails.config.locations.add "file:" + System.getProperty(ENV_NAME)
} else if(new File(default_config).exists()) {
    println "[${appName}] Including default configuration file: " + default_config;
    grails.config.locations.add "file:" + default_config
} else {
    println "[${appName}] No external configuration file defined."
}

println "[${appName}] (*) grails.config.locations = ${grails.config.locations}"

/******************************************************************************\
 *  RELOADABLE CONFIG
 \******************************************************************************/
reloadable.cfgs = ["file:/data/${appName}/config/${appName}-config.properties"]

bie.baseUrl = "http://bie.ala.org.au"
bieService.baseUrl = "http://bie.ala.org.au/ws"
biocache.baseUrl = "http://biocache.ala.org.au/ws"
biocacheUi.baseUrl = "http://biocache.ala.org.au"
biocache.validation.url = "http://biocache.ala.org.au/ws/process/adhoc"
layers.service.url = "http://spatial.ala.org.au/ws"
ecodata.baseUrl = "http://ecodata-sightings-dev.ala.org.au/ws"
taxonoverflow.baseUrl = "http://taxonoverflow-dev.ala.org.au"
hideTaxonOverflowLinks = false
media.uploadDir = "/data/${appName}/cache/imageUploads/" // Path to where files will be uploaded
coordinates.sources = ["Google maps", "Google earth", "GPS device", "camera/phone", "physical maps", "other"]
sighting.fields.excludes = ['errors','timeZoneOffset','eventDateNoTime','eventDateTime','class','log','constraints','$constraints']
sighting.licenses = ['Creative Commons Attribution','Creative Commons Attribution-Noncommercial','Creative Commons Attribution-Share Alike','Creative Commons Attribution-Noncommercial-Share Alike']
sortFields=['scientificName','commonName','eventDate','dateCreated','lastUpdated','locality','multimedia']
accuracyValues=[0,10,50,100,500,1000,5000,10000]
//flag.issues = ['Identification','Geocoding Issue','Suspected Outlier','Temporal Issue','Taxonomic Issue','Habitat Issue']
flag.issues = ['IDENTIFICATION','GEOCODING_ISSUE','TEMPORAL_ISSUE','HABITAT_ISSUE','--','INAPPROPRIATE_IMAGE']
showBiocacheLinks = false
identify.subgroupFacet = "names_and_lsid"

identify.enabled = true

grails.project.groupId = "au.org.ala" // change this to alter the default package name and Maven publishing destination

// bootstrap 3
grails.plugins.twitterbootstrap.fixtaglib = true

// The ACCEPT header will not be used for content negotiation for user agents containing the following strings (defaults to the 4 major rendering engines)
grails.mime.disable.accept.header.userAgents = ['Gecko', 'WebKit', 'Presto', 'Trident']
grails.mime.types = [ // the first one is the default format
    all:           '*/*', // 'all' maps to '*' or the first available format in withFormat
    atom:          'application/atom+xml',
    css:           'text/css',
    csv:           'text/csv',
    form:          'application/x-www-form-urlencoded',
    html:          ['text/html','application/xhtml+xml'],
    js:            'text/javascript',
    json:          ['application/json', 'text/json'],
    multipartForm: 'multipart/form-data',
    rss:           'application/rss+xml',
    text:          'text/plain',
    hal:           ['application/hal+json','application/hal+xml'],
    xml:           ['text/xml', 'application/xml']
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// What URL patterns should be processed by the resources plugin
grails.resources.adhoc.patterns = ['/images/*', '/css/*', '/js/*', '/plugins/*']
grails.resources.adhoc.includes = ['/images/**', '/css/**', '/js/**', '/plugins/**']

grails.databinding.dateFormats = ["dd-MM-yyyy", "yyyy-MM-dd HH:mm:ss.S", "yyyy-MM-dd'T'hh:mm:ss'Z'"]

// Legacy setting for codec used to encode data with ${}
grails.views.default.codec = "html"
grails.mime.file.extensions = true
//grails.mime.use.accept.header = false

// The default scope for controllers. May be prototype, session or singleton.
// If unspecified, controllers are prototype scoped.
grails.controllers.defaultScope = 'singleton'

// GSP settings
grails {
    views {
        gsp {
            encoding = 'UTF-8'
            htmlcodec = 'xml' // use xml escaping instead of HTML4 escaping
            codecs {
                expression = 'none' // escapes values inside ${}
                scriptlet = 'none' // escapes output from scriptlets in GSPs
                taglib = 'none' // escapes output from taglibs
                staticparts = 'none' // escapes output from static template parts
            }
        }
        // escapes all not-encoded output at final stage of outputting
        // filteringCodecForContentType.'text/html' = 'html'
    }
}


grails.converters.encoding = "UTF-8"
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []
// whether to disable processing of multi part requests
grails.web.disable.multipart=false

// request parameters to mask when logging exceptions
grails.exceptionresolver.params.exclude = ['password']

// configure auto-caching of queries by default (if false you can cache individual queries with 'cache: true')
grails.hibernate.cache.queries = false

// configure passing transaction's read-only attribute to Hibernate session, queries and criterias
// set "singleSession = false" OSIV mode in hibernate configuration after enabling
grails.hibernate.pass.readonly = false
// configure passing read-only to OSIV session by default, requires "singleSession = false" OSIV mode
grails.hibernate.osiv.readonly = false

// mail plugin
grails.mail.host = "smtp.csiro.au" // should override this in config (non public hostname)
grails.mail.default.from = "info@ala.org.au"
grails.mail.default.to = "support@ala.org.au"

environments {
    development {
        grails.logging.jul.usebridge = true
        grails.mail.overrideAddress = "nick.dosremedios@csiro.au"
    }
    test {
    }
    production {
    }
}

def loggingDir = (System.getProperty('catalina.base') ? System.getProperty('catalina.base') + '/logs' : './logs')
if(!(new File(loggingDir).exists())){
    loggingDir = "/tmp"
}

// log4j configuration
log4j = {
// Example of changing the log pattern for the default console
// appender:
    appenders {
        environments {
            production {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "${loggingDir}/${appName}.log", threshold: org.apache.log4j.Level.ERROR, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
            }
            development {
                console name: "stdout", layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n"), threshold: org.apache.log4j.Level.DEBUG
            }
            test {
                rollingFile name: "tomcatLog", maxFileSize: '1MB', file: "/tmp/${appName}", threshold: org.apache.log4j.Level.DEBUG, layout: pattern(conversionPattern: "%d %-5p [%c{1}] %m%n")
            }
        }
    }
    root {
    // change the root logger to my tomcatLog file
        error 'tomcatLog'
        warn 'tomcatLog'
        additivity = true
    }

    error   'au.org.ala.cas.client',
            'grails.spring.BeanBuilder',
            'grails.plugin.webxml',
            'grails.plugin.cache.web.filter',
            'grails.app.services.org.grails.plugin.resource',
            'grails.app.taglib.org.grails.plugin.resource',
            'grails.app.resourceMappers.org.grails.plugin.resource'

    debug   'grails.app'
}