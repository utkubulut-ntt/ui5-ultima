import { $ManagedObjectSettings } from "sap/ui/base/ManagedObject";
import { PropertyGetter, PropertySetter } from "{{UI5_PATH}}/types/global/CustomClass.types";

declare module "{{UI5_PATH}}/lib/core/Base" {
    export default interface Base {
        getODataModelName: PropertyGetter<string | undefined>;
        setODataModelName: PropertySetter<string | undefined>;
        getFragmentBasePath: PropertyGetter<string | undefined>;
        setFragmentBasePath: PropertySetter<string | undefined>;
        getEnableBusy: PropertyGetter<boolean | undefined>;
        setEnableBusy: PropertySetter<boolean | undefined>;
    }
}

export type BaseSettings = $ManagedObjectSettings & {
    oDataModelName?: string;
    fragmentBasePath?: string;
    enableBusy?: boolean;
};