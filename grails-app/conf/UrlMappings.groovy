class UrlMappings {

	static mappings = {
        "/$controller/$action?/$id?(.$format)?"{
            constraints {
                // apply constraints here
            }
        }
        "/identify"(view:"/identify")
        "/"(view:"/index")
        "500"(view:'/error')
	}
}
