import { ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

export type ODataFunctionResponseSettings = {
    successful: boolean;
    data?: any;
    errorResponse?: ODataRequestError;
};