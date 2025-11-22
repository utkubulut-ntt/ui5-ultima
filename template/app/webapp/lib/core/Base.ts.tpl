import ManagedObject from "sap/ui/base/ManagedObject";
import BaseController from "{{UI5_PATH}}/controller/BaseController";
import { BaseSettings } from "{{UI5_PATH}}/types/core/Base.types";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";
// ODATA_BLOCK_START
import ODataService from "{{UI5_PATH}}/lib/odata/ODataService";
// ODATA_BLOCK_END
// FRAGMENT_BLOCK_START
import FragmentService from "{{UI5_PATH}}/lib/core/FragmentService";
// FRAGMENT_BLOCK_END

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
    // ODATA_BLOCK_START
    protected readonly odata: ODataService;
    // ODATA_BLOCK_END
    // FRAGMENT_BLOCK_START
    protected readonly fragment: FragmentService;
    // FRAGMENT_BLOCK_END

    constructor(controller: BaseController, settings?: BaseSettings) {
        super(settings);
        this.controller = controller;
        
        // ODATA_BLOCK_START
        this.odata = new ODataService(controller, {
            modelName: settings?.oDataModelName,
            enableBusy: settings?.enableBusy
        });
        // ODATA_BLOCK_END

        // FRAGMENT_BLOCK_START
        this.fragment = new FragmentService(this.controller, {
            basePath: settings?.fragmentBasePath
        });
        // FRAGMENT_BLOCK_END
    }
}