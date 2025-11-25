# UI5 Ultima

UI5 Ultima is a CLI tool to generate free-style SAPUI5 applications and artifacts with TypeScript. The UI5 Ultima comes with some useful built-in SAPUI5 classes.

## Built-in Classes

- **BaseController:** It must be used as the super class for all Controller classes. It provides some useful utility methods. Additionally, it provides instances for **ODataService** and **Fragment** classes.

- **Base:** It is an abstract class providing ODataService and Fragment class instances. Additionally, it includes a reference to the target controller to use utility methods provided by the **BaseController** class. Any custom SAPUI5 class can extend this class to use **BaseController**, **ODataService**, and **Fragment** class capabilities.

- **ODataService:** This class utilizes the **sap.ui.model.odata.v2.ODataModel** class of standard SAPUI5 library to provide better OData methods in a promisified way. All OData operations in the application must be managed via this class. It includes methods for CRUD operations and is able to parse the error messages coming from a CAP server.

- **Fragment:** This class provides methods for loading **.fragment.xml** file content. Additionally, it provides methods for managing (open, close, destroy) **sap.m.Dialog** instances located in a **.fragment.xml** file. This class can handle **Escape** event of any sap.m.Dialog instance and reset the OData context if it is passed through the **openDialog()** method to avoid **submitChanges** bugs.

## Installation

To use the UI5 Ultima, install the npm package globally using the following command:

```bash
npm install -g ui5-ultima
```

## Usage

The UI5 Ultima includes all the descriptions for the available commands. Use the following command to display all available commands with their descriptions:

```bash
ui5-ultima --help
```