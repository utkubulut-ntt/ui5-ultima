{
    "welcomeFile": "/index.html",
    "authenticationMethod": "route",
    "routes": [
        // ROUTE_BLOCK_START
        {{DEFAULT_UI_ROUTE}}
        // ROUTE_BLOCK_END
        {
            "source": "^(.*)$",
            "target": "$1",
            "service": "html5-apps-repo-rt",
            "authenticationType": "xsuaa",
            "cacheControl": "no-cache"
        }
    ]
}