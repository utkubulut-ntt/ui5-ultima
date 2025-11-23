export type ManifestContent = {
    "sap.app"?: {
        id?: string;
    };
    "sap.ui5"?: {
        routing?: {
            routes?: Route[];
            targets?: Record<string, Target>;
        };
    };
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