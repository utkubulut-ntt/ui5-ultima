export type ManifestContent = {
    "sap.app"?: {
        id?: string;
        dataSources?: Record<string, DataSource>;
    };
    "sap.ui5"?: {
        routing?: {
            routes?: Route[];
            targets?: Record<string, Target>;
        };
    };
};

export type TemplateManifestContent = {
    "sap.app": {
        id: string;
        dataSources?: Record<string, DataSource>;
    };
    "sap.ui5": {
        models: Record<string, Model>;
    };
};

export type DataSource = {
    uri: string;
    type: "OData" | "JSON";
    settings: {
        localUri?: string;
        odataVersion?: "2.0" | "4.0";
    };
};

export type Model = {
    dataSource?: string;
    preload?: boolean;
    settings?: Record<string, any>;
};

export type Route = {
    name: string;
    pattern: string;
    target: string[];
};

export type Target = {
    id: string;
    name: string;
    type: "View";
    viewType: "XML";
    transition: "slide";
    clearControlAggregation: false;
};