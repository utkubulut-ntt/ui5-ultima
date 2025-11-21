import { ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

export type ODataActionResponseSettings = {
    successful: boolean;
    data?: any;
    errorResponse?: ODataRequestError;
};