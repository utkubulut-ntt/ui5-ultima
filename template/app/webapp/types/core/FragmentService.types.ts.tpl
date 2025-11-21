import { $ManagedObjectSettings } from "sap/ui/base/ManagedObject";
import Context from "sap/ui/model/odata/v2/Context";
import { PropertyGetter, PropertySetter } from "{{UI5_PATH}}/types/global/CustomClass.types";

declare module "{{UI5_PATH}}/lib/core/FragmentService" {
    export default interface FragmentService {
        getBasePath: PropertyGetter<string>;
        setBasePath: PropertySetter<string>;
    }
}

export type FragmentServiceSettings = $ManagedObjectSettings & {
    basePath?: string;
};

export type OpenDialogSettings = {
    handleEscape?: boolean;
    context?: Context;
    resetContextOnClose?: boolean;
    title?: string;
};

export type DialogEscapeEvent = {
    resolve: Function;
    reject: Function;
};