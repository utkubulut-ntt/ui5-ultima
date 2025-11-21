{
    "name": "{{UI_MODULE}}",
    "version": "1.0.0",
    "description": "{{DESCRIPTION}}",
    "keywords": [
        "ui5",
        "openui5",
        "sapui5"
    ],
    "main": "webapp/index.html",
    "devDependencies": {
        "@ui5/cli": "^4",
        "@sap/ux-ui5-tooling": "^1",
        "@sapui5/types": "{{VERSION}}",
        "ui5-tooling-transpile": "^3",
        "typescript": "^5",
        "@typescript-eslint/eslint-plugin": "^8",
        "@typescript-eslint/parser": "^8",
        "@sap-ux/eslint-plugin-fiori-tools": "^0",
        "@sap/ui5-builder-webide-extension": "^1",
        "ui5-task-zipper": "^3"
    },
    "scripts": {
        "start": "ui5 serve --port 8080 -o index.html",
        "deploy-config": "fiori add deploy-config cf",
        "build:prod": "ui5 build preload --clean-dest --config ui5-build-prod.yaml --include-task=generateCachebusterInfo",
        "build:dev": "ui5 build --config ui5-build-dev.yaml --exclude-task=uglify --exclude-task=cssmin --exclude-task=minify --exclude-task=generateComponentPreload --exclude-task=generateCachebusterInfo --exclude-task=generateVersionInfo --exclude-task=generateFlexChangesBundle"
    }
}