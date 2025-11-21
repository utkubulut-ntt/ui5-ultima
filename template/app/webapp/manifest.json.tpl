{
    "_version": "1.73.1",
    "sap.app": {
        "id": "{{NAMESPACE}}",
        "type": "application",
        "i18n": {
            "bundleUrl": "i18n/i18n.properties",
            "supportedLocales": [
                ""
            ],
            "fallbackLocale": ""
        },
        "applicationVersion": {
            "version": "1.0.0"
        },
        "title": "{{global.title.appTitle}}",
        "description": "{{global.info.appDescription}}"
    },
    "sap.ui": {
        "technology": "UI5",
        "icons": {
            "icon": "",
            "favIcon": "",
            "phone": "",
            "phone@2": "",
            "tablet": "",
            "tablet@2": ""
        },
        "deviceTypes": {
            "desktop": true,
            "tablet": true,
            "phone": true
        }
    },
    "sap.ui5": {
        "flexEnabled": false,
        "dependencies": {
            "minUI5Version": "{{VERSION}}",
            "libs": {
                "sap.m": {},
                "sap.ui.core": {},
                "sap.f": {},
                "sap.suite.ui.generic.template": {},
                "sap.ui.comp": {},
                "sap.ui.generic.app": {},
                "sap.ui.table": {},
                "sap.ushell": {}
            }
        },
        "contentDensities": {
            "compact": true,
            "cozy": true
        },
        "models": {
            "i18n": {
                "type": "sap.ui.model.resource.ResourceModel",
                "settings": {
                    "bundleName": "{{NAMESPACE}}.i18n.i18n",
                    "supportedLocales": [
                        ""
                    ],
                    "fallbackLocale": ""
                }
            }
        },
        "resources": {
            "css": [
                {
                    "uri": "css/style.css"
                }
            ]
        },
        "routing": {
            "config": {
                "routerClass": "sap.m.routing.Router",
                "viewType": "XML",
                "async": true,
                "path": "{{NAMESPACE}}.view",
                "controlAggregation": "pages",
                "controlId": "app",
                "clearControlAggregation": false
            },
            "routes": [
                {
                    "name": "Route{{VIEW}}",
                    "pattern": "",
                    "target": [
                        "Target{{VIEW}}"
                    ]
                }
            ],
            "targets": {
                "Target{{VIEW}}": {
                    "id": "{{VIEW}}",
                    "name": "{{VIEW}}",
                    "type": "View",
                    "viewType": "XML",
                    "transition": "slide",
                    "clearControlAggregation": false
                }
            }
        },
        "rootView": {
            "viewName": "{{NAMESPACE}}.view.App",
            "type": "XML",
            "async": true,
            "id": "App"
        }
    }
}