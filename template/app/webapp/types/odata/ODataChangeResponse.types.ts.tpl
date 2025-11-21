import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";
import {
    ChangeResponse,
    ErrorResponse,
    ODataRequestError,
    ODataResponse,
    ODataSubmitChangesRawResponse
} from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

export type ODataChangeResponseSettings = {
    successful: boolean;
    statusCode: string;
    errorMessage?: string;
    errorType: ODataErrorType;
    response?: ODataResponse;
    rawResponse?: ODataSubmitChangesRawResponse | ChangeResponse | ODataResponse | ErrorResponse | ODataRequestError;
};