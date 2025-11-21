import ManagedObject from "sap/ui/base/ManagedObject";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataActionResponseSettings } from "{{UI5_PATH}}/types/odata/ODataActionResponse.types";
import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";
import { ErrorResponseBody, ODataRequestError } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataActionResponse extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            successful: { type: "boolean", visibility: "hidden" },
            statusCode: { type: "string", visibility: "hidden" },
            errorMessage: { type: "string", visibility: "hidden" },
            errorType: { type: "string", visibility: "hidden" },
            errorResponse: { type: "object", visibility: "hidden" },
            data: { type: "any", visibility: "hidden" }
        }
    };

    constructor(settings: ODataActionResponseSettings) {
        super();
        this.setProperty("successful", settings.successful);
        this.setProperty("errorType", "BUSINESS_LOGIC");
        this.setProperty("errorResponse", settings.errorResponse);

        if (settings.data != null) {
            if (Array.isArray(settings.data)) {
                const data: Record<string, any>[] = [];

                for (const record of settings.data) {
                    const { __metadata, ...rec } = record;
                    data.push(rec);
                }

                this.setProperty("data", data);
            } else {
                if (typeof settings.data === "object" && "__metadata" in settings.data) {
                    const { __metadata, ...record } = settings.data;
                    this.setProperty("data", record);
                } else {
                    this.setProperty("data", settings.data);
                }
            }
        } else {
            this.setProperty("data", []);
        }

        if (settings.successful) {
            this.setProperty("statusCode", "200");
        } else {
            this.parseError(settings.errorResponse);
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

    public getErrorResponse() {
        return this.getProperty("errorResponse") as ODataRequestError | undefined;
    }

    public getData<DataT = any>() {
        return this.getProperty("data") as DataT;
    }

    private parseError(errorResponse?: ODataRequestError) {
        const statusCode = errorResponse?.statusCode || "500";
        this.setProperty("statusCode", statusCode);

        if (errorResponse?.responseText && typeof errorResponse.responseText === "string") {
            try {
                const parsedBody = JSON.parse(errorResponse.responseText);

                if (this.isErrorResponseBody(parsedBody)) {
                    this.setProperty("errorMessage", parsedBody.error?.message?.value);

                    if (parsedBody.error?.code === "404") {
                        this.setProperty("errorType", "NOT_FOUND");
                    }
                }
            } catch (error) {
                this.setProperty("errorMessage", errorResponse.responseText);
            }
        }
    }

    private isErrorResponseBody(body: any): body is ErrorResponseBody {
        return body != null && typeof body === "object" && "error" in body && body.error != null && typeof body.error === "object";
    }
}