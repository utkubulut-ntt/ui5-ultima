import ManagedObject from "sap/ui/base/ManagedObject";
import ODataChangeResponse from "{{UI5_PATH}}/lib/odata/ODataChangeResponse";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";
import {
    ChangeResponse,
    ErrorResponse,
    ErrorResponseBody,
    ODataRequestError,
    ODataSubmitChangesRawResponse,
    ODataSubmitResponseSettings
} from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataSubmitResponse extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            rawResponse: { type: "object" },
            successful: { type: "boolean", visibility: "hidden" },
            statusCode: { type: "string", visibility: "hidden" },
            errorMessage: { type: "string", visibility: "hidden" },
            errorType: { type: "string", visibility: "hidden" }
        },
        aggregations: {
            changeResponses: {
                type: "{{NAMESPACE}}.lib.odata.ODataChangeResponse",
                multiple: true,
                singularName: "changeResponse"
            }
        }
    };

    constructor(settings?: ODataSubmitResponseSettings) {
        super(settings);
        this.setProperty("errorType", "BUSINESS_LOGIC");
        this.parse(settings?.rawResponse);
    }

    public first() {
        return this.getAllChangeResponses()[0] as ODataChangeResponse;
    }

    public getAllChangeResponses() {
        const changeResponses = this.getAggregation("changeResponses") as ODataChangeResponse[];
        return changeResponses;
    }

    public isSuccessful() {
        return this.getProperty("successful") as boolean;
    }

    public getStatusCode() {
        return this.getProperty("statusCode") as string;
    }

    public getErrorMessage() {
        return this.getProperty("errorMessage") as string | undefined;
    }

    public getErrorType() {
        return this.getProperty("errorType") as ODataErrorType;
    }

    private parse(rawResponse?: ODataSubmitChangesRawResponse | ODataRequestError) {
        if (!rawResponse) {
            this.setProperty("successful", false);
            this.setProperty("statusCode", "500");
            this.addAggregation("changeResponses", new ODataChangeResponse({
                successful: false,
                statusCode: this.getStatusCode(),
                errorType: this.getErrorType(),
                rawResponse: this.getRawResponse()
            }));

            return;
        }

        if (this.isBatchResponse(rawResponse)) {
            this.parseStatus(rawResponse);
            this.parseChangeResponses(rawResponse);
        } else {
            this.parseRequestError(rawResponse);
        }
    }

    private parseStatus(rawResponse: ODataSubmitChangesRawResponse) {
        const batchResponses = rawResponse.__batchResponses || [];

        if (!batchResponses.length) {
            this.setProperty("successful", false);
            this.setProperty("statusCode", "500");
            this.addAggregation("changeResponses", new ODataChangeResponse({
                successful: false,
                statusCode: this.getStatusCode(),
                errorType: this.getErrorType(),
                rawResponse: this.getRawResponse()
            }));

            return;
        }

        for (const response of batchResponses) {
            if (this.isChangeResponse(response)) {
                this.setProperty("successful", true);
                this.setProperty("statusCode", "200");
                break;
            }

            if (this.isErrorResponse(response)) {
                const statusCode = response.response?.statusCode || "500";
                this.setProperty("statusCode", statusCode);

                if (statusCode.startsWith("4") || statusCode.startsWith("5")) {
                    const errorBody = response.response?.body;

                    if (errorBody) {
                        try {
                            const parsedBody = JSON.parse(errorBody);

                            if (this.isErrorResponseBody(parsedBody)) {
                                const errorCode = parsedBody.error?.code || "0";
                                this.setProperty("errorMessage", parsedBody.error?.message?.value);

                                switch (errorCode) {
                                    case "301":
                                        this.setProperty("errorType", "UNIQUE_CONSTRAINT_VIOLATION");
                                        break;
                                    case "404":
                                        this.setProperty("errorType", "NOT_FOUND");
                                        break;
                                }
                            }
                        } catch (error) {
                            this.setProperty("errorMessage", errorBody);
                        }
                    }

                    this.setProperty("successful", false);
                    this.addAggregation("changeResponses", new ODataChangeResponse({
                        successful: false,
                        statusCode: this.getStatusCode(),
                        errorMessage: this.getErrorMessage(),
                        errorType: this.getErrorType(),
                        rawResponse: response
                    }));
                } else {
                    this.setProperty("successful", true);
                }
            } else if (this.hasStatusCode(response)) {
                const statusCode = response.statusCode || "500";
                this.setProperty("statusCode", statusCode);

                if (statusCode.startsWith("4") || statusCode.startsWith("5")) {
                    this.setProperty("successful", false);
                    this.addAggregation("changeResponses", new ODataChangeResponse({
                        successful: false,
                        statusCode: this.getStatusCode(),
                        errorType: this.getErrorType(),
                        response: response
                    }));
                } else {
                    this.setProperty("successful", true);
                }
            } else {
                this.setProperty("successful", false);
                this.setProperty("statusCode", "500");
                this.addAggregation("changeResponses", new ODataChangeResponse({
                    successful: false,
                    statusCode: this.getStatusCode(),
                    errorType: this.getErrorType(),
                    rawResponse: this.getRawResponse()
                }));
            }
        }
    }

    private parseChangeResponses(rawResponse: ODataSubmitChangesRawResponse) {
        const batchResponses = rawResponse.__batchResponses || [];

        if (!this.isSuccessful() || !batchResponses.length) {
            this.addAggregation("changeResponses", new ODataChangeResponse({
                successful: false,
                statusCode: this.getStatusCode(),
                errorMessage: this.getErrorMessage(),
                errorType: this.getErrorType(),
                rawResponse: this.getRawResponse()
            }));

            return;
        }

        for (const batch of batchResponses) {
            if (this.isChangeResponse(batch)) {
                const changeResponses = batch.__changeResponses || [];

                for (const change of changeResponses) {
                    this.addAggregation("changeResponses", new ODataChangeResponse({
                        successful: this.isSuccessful(),
                        statusCode: change.statusCode || this.getStatusCode(),
                        errorMessage: this.getErrorMessage(),
                        errorType: this.getErrorType(),
                        response: change,
                        rawResponse: change
                    }));
                }
            }
        }
    }

    private parseRequestError(rawResponse: ODataRequestError) {
        const statusCode = rawResponse.statusCode?.toString() || "500";
        const errorMessage = rawResponse.responseText;

        this.setProperty("successful", false);
        this.setProperty("statusCode", statusCode);
        this.setProperty("errorMessage", errorMessage);
        this.addAggregation("changeResponses", new ODataChangeResponse({
            successful: false,
            statusCode: this.getStatusCode(),
            errorMessage: this.getErrorMessage(),
            errorType: this.getErrorType(),
            rawResponse: rawResponse
        }));
    }

    private isBatchResponse(response: any): response is ODataSubmitChangesRawResponse {
        return response != null && typeof response === "object" && "__batchResponses" in response && response.__batchResponses != null;
    }

    private isChangeResponse(response: any): response is ChangeResponse {
        return response != null && typeof response === "object" && "__changeResponses" in response && response.__changeResponses != null;
    }

    private isErrorResponse(response: any): response is ErrorResponse {
        return response != null && typeof response === "object" && "message" in response;
    }

    private isErrorResponseBody(body: any): body is ErrorResponseBody {
        return body != null && typeof body === "object" && "error" in body && body.error != null && typeof body.error === "object";
    }

    private hasStatusCode(response: any): response is { statusCode?: string; } {
        return response != null && typeof response === "object" && "statusCode" in response;
    }
}