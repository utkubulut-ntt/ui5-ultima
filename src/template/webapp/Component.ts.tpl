import UIComponent from "sap/ui/core/UIComponent";
import { createDeviceModel } from "{{UI5_PATH}}/model/models";
import { ComponentMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";

/**
 * @namespace {{NAMESPACE}}
 */
export default class Component extends UIComponent {
    public static metadata: ComponentMetadata = {
        manifest: "json"
    };

    public override init() {
        super.init();
        this.getRouter().initialize();
        this.setModel(createDeviceModel(), "device");
    }
}