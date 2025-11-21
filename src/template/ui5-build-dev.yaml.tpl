# yaml-language-server: $schema=https://ui5.github.io/cli/schema/ui5.yaml.json
specVersion: '4.0'
metadata:
  name: {{NAMESPACE}}
type: application
resources:
  configuration:
    propertiesFileSourceEncoding: UTF-8
builder:
  resources:
    excludes:
      - "/test/**"
      - "/localService/**"
  customTasks:
    - name: webide-extension-task-updateManifestJson
      afterTask: replaceVersion
      configuration:
        appFolder: webapp
        destDir: dist
    - name: ui5-tooling-transpile-task
      afterTask: replaceVersion
      configuration:
        debug: false
        removeConsoleStatements: false
        transformAsyncToPromise: false
        transformTypeScript: true
        transformModulesToUI5: true