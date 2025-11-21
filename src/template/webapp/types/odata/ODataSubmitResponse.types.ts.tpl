import { $ManagedObjectSettings } from "sap/ui/base/ManagedObject";
import { PropertyGetter, PropertySetter } from "{{UI5_PATH}}/types/global/CustomClass.types";

declare module "{{UI5_PATH}}/lib/odata/ODataSubmitResponse" {
    export default interface ODataSubmitResponse {
        getRawResponse: PropertyGetter<ODataSubmitChangesRawResponse | ODataRequestError | undefined>;
        setRawResponse: PropertySetter<ODataSubmitChangesRawResponse | ODataRequestError | undefined>;
    }
}

export type ODataSubmitResponseSettings = $ManagedObjectSettings & {
    rawResponse?: ODataSubmitChangesRawResponse | ODataRequestError;
};

export type ODataSubmitChangesRawResponse = {
    __batchResponses?: Array<ChangeResponse | ODataResponse | ErrorResponse>;
};

export type ChangeResponse = {
    __changeResponses?: ODataResponse[];
};

export type ODataResponse = {
    _imported?: boolean;
    $reported?: boolean;
    statusCode?: string;
    statusText?: string;
    headers?: Record<string, any>;
    body?: string;
    data?: Record<string, any>;
};

export type ErrorResponse = {
    $reported?: boolean;
    message?: string;
    response?: ErrorResponseObject;
};

export type ErrorResponseObject = {
    statusCode?: string;
    statusText?: string;
    headers?: Record<string, any>;
    body?: string;
};

export type ErrorResponseBody = {
    error?: {
        ContentID?: string;
        code?: string;
        innererror?: {
            errordetails?: InnerErrorDetails[];
        };
        message?: {
            lang?: string;
            value?: string;
        };
        severity?: string;
        target?: string;
    };
};

export type InnerErrorDetails = {
    ContentID?: string;
    code?: string;
    message?: {
        lang?: string;
        value?: string;
    };
    severity?: string;
    target?: string;
};

export type ODataRequestError = {
    message?: string;
    statusCode?: number;
    statusText?: string;
    headers?: object[];
    responseText?: string;
};