import ManagedObject from "sap/ui/base/ManagedObject";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import { ODataChangeResponseSettings } from "{{UI5_PATH}}/types/odata/ODataChangeResponse.types";
import { ODataErrorType } from "{{UI5_PATH}}/types/odata/ODataService.types";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataChangeResponse extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            successful: { type: "boolean", visibility: "hidden" },
            statusCode: { type: "string", visibility: "hidden" },
            errorMessage: { type: "string", visibility: "hidden" },
            errorType: { type: "string", visibility: "hidden" },
            data: { type: "object", visibility: "hidden" },
            rawResponse: { type: "object", visibility: "hidden" }
        }
    };

    constructor(settings: ODataChangeResponseSettings) {
        super();
        this.setProperty("successful", settings.successful);
        this.setProperty("statusCode", settings.statusCode);
        this.setProperty("errorMessage", settings.errorMessage);
        this.setProperty("errorType", settings.errorType);
        this.setProperty("rawResponse", settings.rawResponse);

        if (settings.successful && settings.response?.data) {
            if (typeof settings.response.data === "object") {
                const { __metadata, ...data } = settings.response.data;
                this.setProperty("data", data);
            }
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

    public getData<DataT extends Record<string, any> = Record<string, any>>() {
        return this.getProperty("data") as DataT;
    }

    public getRawResponse() {
        const rawResponse: ODataChangeResponseSettings["rawResponse"] = this.getProperty("rawResponse");
        return rawResponse;
    }
}