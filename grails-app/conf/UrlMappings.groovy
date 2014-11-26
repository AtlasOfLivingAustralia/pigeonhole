class UrlMappings {

	static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }
        "/identify"(view:"/identify")
        "/identifyn-ng"(view:"/identify-ng")
        "/submit/$lsid**"(controller: "/submitSighting")
        "/uploads/$file**"(controller:"image", action:"index")
        "/"(view:"/index")
        "500"(view:'/error')
	}
}
