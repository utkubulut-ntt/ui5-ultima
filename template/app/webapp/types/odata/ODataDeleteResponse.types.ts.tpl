import { $ManagedObjectSettings } from "sap/ui/base/ManagedObject";
import { PropertyGetter, PropertySetter } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

declare module "{{UI5_PATH}}/lib/odata/ODataDeleteResponse" {
    export default interface ODataDeleteResponse {
        getErrorResponse: PropertyGetter<ODataRequestError | undefined>;
        setErrorResponse: PropertySetter<ODataRequestError | undefined>;
    }
}

export type ODataDeleteResponseSettings = $ManagedObjectSettings & {
    errorResponse?: ODataRequestError;
};