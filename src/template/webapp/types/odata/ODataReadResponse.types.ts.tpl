import { ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

export type ODataReadResponseSettings = {
    successful: boolean;
    data?: Record<string, any> | Record<string, any>[];
    errorResponse?: ODataRequestError;
};