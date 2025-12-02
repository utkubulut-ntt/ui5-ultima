{
    "name": "approuter",
    "dependencies": {
        "@sap/approuter": "^20"
    },
    "engines": {
        "node": "^22.0.0"
    },
    "scripts": {
        "start": "node node_modules/@sap/approuter/approuter.js",
        "build-ui": "npm --prefix ../{{UI_MODULE}} run build:prod",
        "sl": "npm run build-ui && node --env-file=.env node_modules/@sap/html5-repo-mock/index.js"
    },
    "devDependencies": {
        "@sap/html5-repo-mock": "2.1.10"
    }
}