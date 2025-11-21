import ManagedObject from "sap/ui/base/ManagedObject";
import ODataModel from "sap/ui/model/odata/v2/ODataModel";
import { ODataReadParameters, ODataServiceSettings, UserReadByKeyParameters, UserReadParameters } from "{{UI5_PATH}}/types/odata/ODataService.types";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
import Context from "sap/ui/model/odata/v2/Context";
import BusyIndicator from "sap/ui/core/BusyIndicator";
import { ODataRequestError, ODataSubmitChangesRawResponse } from "{{UI5_PATH}}/types/odata/ODataSubmitResponse.types";
import ODataSubmitResponse from "{{UI5_PATH}}/lib/odata/ODataSubmitResponse";
import ODataModifyResponse from "{{UI5_PATH}}/lib/odata/ODataModifyResponse";
import ODataDeleteResponse from "{{UI5_PATH}}/lib/odata/ODataDeleteResponse";
import ODataReadResponse from "{{UI5_PATH}}/lib/odata/ODataReadResponse";
import BaseController from "{{UI5_PATH}}/controller/BaseController";
import ODataFunctionResponse from "{{UI5_PATH}}/lib/odata/ODataFunctionResponse";
import ODataActionResponse from "{{UI5_PATH}}/lib/odata/ODataActionResponse";

/**
 * @namespace {{NAMESPACE}}.lib.odata
 */
export default class ODataService extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            modelName: { type: "string" },
            enableBusy: { type: "boolean", defaultValue: true }
        }
    };
    private readonly controller: BaseController;

    constructor(controller: BaseController, settings?: ODataServiceSettings) {
        super(settings);
        this.controller = controller;
        this.initialize(settings);
    }

    public getModelInstance() {
        const model = this.getModel();

        if (model instanceof ODataModel === false) {
            throw new Error("The sap.ui.model.odata.v2.ODataModel instance was not found. Please check your application settings and ODataModel name.");
        }

        return model;
    }

    public createEntry<DataT extends Record<string, any> = Record<string, any>>(path: string, initialData?: DataT) {
        return this.getModelInstance().createEntry(this.getPath(path), {
            properties: initialData
        }) as Context;
    }

    public createKey<KeyT extends Record<string, any> = Record<string, any>>(entity: string, keys: KeyT) {
        return this.getModelInstance().createKey(this.getPath(entity), keys);
    }

    public submitChanges(): Promise<ODataSubmitResponse> {
        return new Promise((resolve) => {
            const model = this.getModelInstance();

            if (model.hasPendingChanges()) {
                this.showBusy();

                model.submitChanges({
                    success: (response?: ODataSubmitChangesRawResponse) => {
                        this.hideBusy();
                        resolve(new ODataSubmitResponse({ rawResponse: response }));
                    },
                    error: (err?: ODataRequestError) => {
                        this.hideBusy();
                        resolve(new ODataSubmitResponse({ rawResponse: err }));
                    }
                });
            }
        });
    }

    public resetChanges(context: Context | Context[]) {
        const pathList = Array.isArray(context) ? context.map(cont => cont.getPath()) : [context.getPath()];
        this.getModelInstance().resetChanges(pathList, true, true);
    }

    public create<DataT extends Record<string, any> = Record<string, any>>(path: string, data: DataT): Promise<ODataModifyResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            this.getModelInstance().create(this.getPath(path), data, {
                success: (response?: Record<string, any>) => {
                    this.hideBusy();
                    resolve(new ODataModifyResponse(true, { rawResponse: response }));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataModifyResponse(false, { rawResponse: err }));
                }
            });
        });
    }

    public update<DataT extends Record<string, any> = Record<string, any>>(path: string, data: DataT): Promise<ODataModifyResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            this.getModelInstance().update(this.getPath(path), data, {
                success: (response?: Record<string, any>) => {
                    this.hideBusy();
                    resolve(new ODataModifyResponse(true, { rawResponse: response }));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataModifyResponse(false, { rawResponse: err }));
                }
            });
        });
    }

    public remove(path: string): Promise<ODataDeleteResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            this.getModelInstance().remove(this.getPath(path), {
                success: () => {
                    this.hideBusy();
                    resolve(new ODataDeleteResponse(true));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataDeleteResponse(false, { errorResponse: err }));
                }
            });
        });
    }

    public delete(context: Context): Promise<ODataDeleteResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            context.delete({
                groupId: "$direct"
            }).then(() => {
                this.hideBusy();
                resolve(new ODataDeleteResponse(true));
            }).catch((err?: ODataRequestError) => {
                this.hideBusy();
                resolve(new ODataDeleteResponse(false, { errorResponse: err }));
            });
        });
    }

    public callFunction<ParamT extends Record<string, any> = Record<string, any>>(path: string, urlParameters?: ParamT): Promise<ODataFunctionResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            const functionPath = this.getPath(path);
            const functionName = functionPath.substring(1);

            this.getModelInstance().callFunction(functionPath, {
                method: "GET",
                urlParameters: urlParameters,
                success: (response?: Record<string, any>) => {
                    this.hideBusy();
                    let data: any | undefined;

                    if (response) {
                        if (this.hasResults(response)) {
                            data = response.results;
                        } else {
                            data = response.hasOwnProperty(functionName) ? response[functionName] : response;
                        }
                    }

                    resolve(new ODataFunctionResponse({ successful: true, data: data }));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataFunctionResponse({ successful: false, errorResponse: err }));
                }
            });
        });
    }

    public callAction<DataT extends Record<string, any> = Record<string, any>>(path: string, data?: DataT) {
        if (data) {
            return this.callActionWithData(path, data);
        } else {
            return this.callActionNoData(path);
        }
    }

    public read(path: string, userParameters?: UserReadParameters): Promise<ODataReadResponse> {
        return new Promise((resolve) => {
            const parameters = this.getReadParameters(userParameters);

            this.showBusy();

            if (parameters) {
                this.getModelInstance().read(this.getPath(path), {
                    ...parameters,
                    success: (response: { results: Record<string, any>[] }) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: true, data: response.results }));
                    },
                    error: (err?: ODataRequestError) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: false, errorResponse: err }));
                    }
                });
            } else {
                this.getModelInstance().read(this.getPath(path), {
                    success: (response: { results: Record<string, any>[] }) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: true, data: response.results }));
                    },
                    error: (err?: ODataRequestError) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: false, errorResponse: err }));
                    }
                });
            }
        });
    }

    public readByKey(path: string, userParameters?: UserReadByKeyParameters): Promise<ODataReadResponse> {
        return new Promise((resolve) => {
            const parameters = this.getReadByKeyParameters(userParameters);

            this.showBusy();

            if (parameters) {
                this.getModelInstance().read(this.getPath(path), {
                    ...parameters,
                    success: (response: Record<string, any>) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: true, data: response }));
                    },
                    error: (err?: ODataRequestError) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: false, errorResponse: err }));
                    }
                });
            } else {
                this.getModelInstance().read(this.getPath(path), {
                    success: (response: Record<string, any>) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: true, data: response }));
                    },
                    error: (err?: ODataRequestError) => {
                        this.hideBusy();
                        resolve(new ODataReadResponse({ successful: false, errorResponse: err }));
                    }
                });
            }
        });
    }

    private initialize(settings?: ODataServiceSettings) {
        const component = this.controller.getComponent();
        const model = component.getModel(settings?.modelName);

        if (model instanceof ODataModel) {
            this.setModel(model);
        }
    }

    private callActionWithData(path: string, data: Record<string, any>): Promise<ODataActionResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            const actionPath = this.getPath(path);
            const actionName = actionPath.substring(1);

            this.getModelInstance().create(actionPath, data, {
                success: (response?: Record<string, any>) => {
                    this.hideBusy();
                    let data: any | undefined;

                    if (response) {
                        if (this.hasResults(response)) {
                            data = response.results;
                        } else {
                            data = response.hasOwnProperty(actionName) ? response[actionName] : response;
                        }
                    }

                    resolve(new ODataActionResponse({ successful: true, data: data }));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataActionResponse({ successful: false, errorResponse: err }));
                }
            });
        });
    }

    private callActionNoData(path: string): Promise<ODataActionResponse> {
        return new Promise((resolve) => {
            this.showBusy();

            const actionPath = this.getPath(path);
            const actionName = actionPath.substring(1);

            this.getModelInstance().callFunction(actionPath, {
                method: "POST",
                success: (response?: Record<string, any>) => {
                    this.hideBusy();
                    let data: any | undefined;

                    if (response) {
                        if (this.hasResults(response)) {
                            data = response.results;
                        } else {
                            data = response.hasOwnProperty(actionName) ? response[actionName] : response;
                        }
                    }

                    resolve(new ODataActionResponse({ successful: true, data: data }));
                },
                error: (err?: ODataRequestError) => {
                    this.hideBusy();
                    resolve(new ODataActionResponse({ successful: false, errorResponse: err }));
                }
            });
        });
    }

    private getReadParameters(userParameters?: UserReadParameters) {
        const parameters: ODataReadParameters = {};

        if (userParameters?.filter) {
            parameters.filters = Array.isArray(userParameters.filter) ? userParameters.filter : [userParameters.filter];
        }

        if (userParameters?.sorter) {
            parameters.sorters = Array.isArray(userParameters.sorter) ? userParameters.sorter : [userParameters.sorter];
        }

        const expand = userParameters?.expand || [];
        const select = userParameters?.select || [];

        this.addReadUrlParameters(parameters, expand, select);

        if (Object.keys(parameters).length) {
            return parameters;
        }
    }

    private getReadByKeyParameters(userParameters?: UserReadByKeyParameters) {
        const parameters: ODataReadParameters = {};

        const expand = userParameters?.expand || [];
        const select = userParameters?.select || [];

        this.addReadUrlParameters(parameters, expand, select);

        if (Object.keys(parameters).length) {
            return parameters;
        }
    }

    private addReadUrlParameters(parameters: ODataReadParameters, expand: string[], select: string[]) {
        if (expand.length || select.length) {
            parameters.urlParameters = {};

            if (expand.length) {
                parameters.urlParameters.$expand = expand.join();
            }

            if (select.length) {
                parameters.urlParameters.$select = select.join();
            }
        }
    }

    private getPath(path: string) {
        return path.startsWith("/") ? path : `/${path}`;
    }

    private showBusy() {
        if (this.getEnableBusy()) {
            BusyIndicator.show(0);
        }
    }

    private hideBusy() {
        if (this.getEnableBusy()) {
            BusyIndicator.hide();
        }
    }

    private hasResults(response: any): response is { results: Record<string, any>[]; } {
        return response != null && typeof response === "object" && "results" in response && Array.isArray(response.results);
    }
}