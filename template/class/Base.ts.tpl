import ManagedObject from "sap/ui/base/ManagedObject";
import BaseController from "{{UI5_PATH}}/controller/BaseController";
import { BaseSettings } from "{{UI5_PATH}}/types/core/Base.types";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";

/**
 * @namespace {{NAMESPACE}}.lib.core
 */
export default abstract class Base extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        abstract: true,
        properties: {
            oDataModelName: { type: "string" },
            fragmentBasePath: { type: "string" },
            enableBusy: { type: "boolean" }
        }
    };
    protected readonly controller: BaseController;

    constructor(controller: BaseController, settings?: BaseSettings) {
        super(settings);
        this.controller = controller;
    }
}