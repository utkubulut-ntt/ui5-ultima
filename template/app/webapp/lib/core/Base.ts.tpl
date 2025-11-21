import ManagedObject from "sap/ui/base/ManagedObject";
import BaseController from "{{UI5_PATH}}/controller/BaseController";
import FragmentService from "{{UI5_PATH}}/lib/core/FragmentService";
import ODataService from "{{UI5_PATH}}/lib/odata/ODataService";
import { BaseSettings } from "{{UI5_PATH}}/types/core/Base.types";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";

/**
 * @namespace {{NAMESPACE}}.lib.core
 */
export default abstract class Base extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        abstract: true,
        properties: {
            controller: { type: "object" },
            oDataModelName: { type: "string" },
            fragmentBasePath: { type: "string" },
            enableBusy: { type: "boolean" }
        }
    };
    protected readonly controller: BaseController;
    protected readonly odata: ODataService;
    protected readonly fragment: FragmentService;

    constructor(controller: BaseController, settings?: BaseSettings) {
        super(settings);
        this.controller = controller;

        this.odata = new ODataService(controller, {
            modelName: settings?.oDataModelName,
            enableBusy: settings?.enableBusy
        });

        this.fragment = new FragmentService(this.controller, {
            basePath: settings?.fragmentBasePath
        });
    }
}