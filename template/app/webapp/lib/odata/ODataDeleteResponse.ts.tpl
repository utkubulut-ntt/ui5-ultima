import ManagedObject from "sap/ui/base/ManagedObject";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataDeleteResponseSettings } from "{{UI5_PATH}}/types/odata/ODataDeleteResponse.types";
import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";
import { ErrorResponseBody, ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataDeleteResponse extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            errorResponse: { type: "object" },
            successful: { type: "boolean", visibility: "hidden" },
            statusCode: { type: "string", visibility: "hidden" },
            errorMessage: { type: "string", visibility: "hidden" },
            errorType: { type: "string", visibility: "hidden" }
        }
    };

    constructor(successful: boolean, settings?: ODataDeleteResponseSettings) {
        super(settings);
        this.setProperty("successful", successful);
        this.setProperty("statusCode", successful ? "204" : "500");
        this.setProperty("errorType", "BUSINESS_LOGIC");

        if (!successful) {
            this.parseError(settings?.errorResponse);
        }
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

    private parseError(rawResponse?: ODataRequestError) {
        const statusCode = rawResponse?.statusCode || "500";
        this.setProperty("statusCode", statusCode);

        if (rawResponse?.responseText && typeof rawResponse.responseText === "string") {
            try {
                const parsedBody = JSON.parse(rawResponse.responseText);

                if (this.isErrorResponseBody(parsedBody)) {
                    this.setProperty("errorMessage", parsedBody.error?.message?.value);

                    if (parsedBody.error?.code === "404") {
                        this.setProperty("errorType", "NOT_FOUND");
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