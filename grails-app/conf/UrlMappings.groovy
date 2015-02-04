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

class UrlMappings {

	static mappings = {
        "/identify"(view:"/identify")
        "/identify-ng"(view:"/identify-ng")
        "/uploads/$file**"(controller:"image", action:"index")
        "/"(controller: "submitSighting", action:"index")
        "/$id**"(controller: "submitSighting", action:"index")
        "/edit/$id**"(controller: "submitSighting", action:"edit")
        "/edit/$id/$guid"(controller: "submitSighting", action:"edit")

        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }

        // "/"(view:"/index")
        "500"(view:'/error')
	}
}
