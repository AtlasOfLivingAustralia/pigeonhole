class UrlMappings {

	static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }
        "/identify"(view:"/identify")
        "/identifyn-ng"(view:"/identify-ng")
        "/submitSighting"(view:"/submitSighting")
        "/uploads/$file**"(controller:"image", action:"index")
        "/"(view:"/index")
        "500"(view:'/error')
	}
}
