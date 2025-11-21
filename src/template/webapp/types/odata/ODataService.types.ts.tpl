import { $ManagedObjectSettings } from "sap/ui/base/ManagedObject";
import Filter from "sap/ui/model/Filter";
import Sorter from "sap/ui/model/Sorter";
import { PropertyGetter, PropertySetter } from "{{UI5_PATH}}/types/global/CustomClass.types";

declare module "{{UI5_PATH}}/lib/odata/ODataService" {
    export default interface ODataService {
        getModelName: PropertyGetter<string | undefined>;
        setModelName: PropertySetter<string | undefined>;
        getEnableBusy: PropertyGetter<boolean>;
        setEnableBusy: PropertySetter<boolean>;
    }
}

export type ODataServiceSettings = $ManagedObjectSettings & {
    modelName?: string;
    enableBusy?: boolean;
};

export type ODataReadParameters = {
    filters?: Filter[];
    sorters?: Sorter[];
    urlParameters?: {
        $expand?: string;
        $select?: string;
    };
};

export type UserReadByKeyParameters = {
    expand?: string[];
    select?: string[];
};

export type UserReadParameters = UserReadByKeyParameters & {
    filter?: Filter | Filter[];
    sorter?: Sorter | Sorter[];
};

export type ODataErrorType = "BUSINESS_LOGIC" | "UNIQUE_CONSTRAINT_VIOLATION" | "NOT_FOUND";