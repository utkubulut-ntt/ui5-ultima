import ManagedObject from "sap/ui/base/ManagedObject";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataModifyRawResponse, ODataModifyResponseSettings } from "{{UI5_PATH}}/types/odata/ODataModifyResponse.types";
import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";
import { ErrorResponseBody, ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataModifyResponse extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            rawResponse: { type: "object" },
            successful: { type: "boolean", visibility: "hidden" },
            statusCode: { type: "string", visibility: "hidden" },
            errorMessage: { type: "string", visibility: "hidden" },
            errorType: { type: "string", visibility: "hidden" },
            data: { type: "object", visibility: "hidden" }
        }
    };

    constructor(successful: boolean, settings?: ODataModifyResponseSettings) {
        super(settings);
        this.setProperty("successful", successful);
        this.setProperty("errorType", "BUSINESS_LOGIC");
        this.parse(settings?.rawResponse);
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

    public getData<DataT extends Record<string, any> = Record<string, any>>() {
        return this.getProperty("data") as DataT;
    }

    private parse(rawResponse?: ODataModifyRawResponse) {
        if (!rawResponse) {
            this.setProperty("statusCode", this.isSuccessful() ? "200" : "500");
            return;
        }

        if (this.isSuccessful()) {
            this.setProperty("statusCode", "200");

            if (typeof rawResponse === "object") {
                const { __metadata, ...data } = rawResponse as Record<string, any>;
                this.setProperty("data", data);
            }
        } else {
            this.parseError(rawResponse);
        }
    }

    private parseError(rawResponse?: ODataRequestError) {
        const statusCode = rawResponse?.statusCode || "500";
        this.setProperty("statusCode", statusCode);

        if (rawResponse?.responseText && typeof rawResponse.responseText === "string") {
            try {
                const parsedBody = JSON.parse(rawResponse.responseText);

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
                this.setProperty("errorMessage", rawResponse.responseText);
            }
        }
    }

    private isErrorResponseBody(body: any): body is ErrorResponseBody {
        return body != null && typeof body === "object" && "error" in body && body.error != null && typeof body.error === "object";
    }
}