# yaml-language-server: $schema=https://ui5.github.io/cli/schema/ui5.yaml.json
specVersion: "4.0"
metadata:
  name: {{NAMESPACE}}
type: application
server:
  customMiddleware:
    - name: fiori-tools-proxy
      afterMiddleware: compression
      configuration:
        ignoreCertError: false
        ui5:
          path:
            - /resources
            - /test-resources
          url: https://sapui5.hana.ondemand.com
          version: {{VERSION}}
    - name: fiori-tools-appreload
      afterMiddleware: compression
      configuration:
        port: 35729
        path: webapp
        delay: 300
    - name: ui5-tooling-transpile-middleware
      afterMiddleware: compression
      configuration:
        debug: false
        removeConsoleStatements: false
        transformAsyncToPromise: false
        transformTypeScript: true
        transformModulesToUI5: true
builder:
  customTasks:
    - name: ui5-tooling-transpile-task
      afterTask: replaceVersion
      configuration:
        debug: false
        removeConsoleStatements: false
        transformAsyncToPromise: false
        transformTypeScript: true
        transformModulesToUI5: true