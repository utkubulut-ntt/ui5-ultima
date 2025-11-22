import ResourceBundle from "sap/base/i18n/ResourceBundle";
import MessageBox from "sap/m/MessageBox";
import BusyIndicator from "sap/ui/core/BusyIndicator";
import UI5Element from "sap/ui/core/Element";
import Controller from "sap/ui/core/mvc/Controller";
import View from "sap/ui/core/mvc/View";
import Route, { Route$PatternMatchedEvent } from "sap/ui/core/routing/Route";
import ResourceModel from "sap/ui/model/resource/ResourceModel";
import Component from "{{UI5_PATH}}/Component";
import formatter from "{{UI5_PATH}}/model/formatter";
// ODATA_BLOCK_START
import ODataService from "{{UI5_PATH}}/lib/odata/ODataService";
// ODATA_BLOCK_END
// FRAGMENT_BLOCK_START
import FragmentService from "{{UI5_PATH}}/lib/core/FragmentService";
// FRAGMENT_BLOCK_END

/**
 * @namespace {{NAMESPACE}}.controller
 */
export default abstract class BaseController extends Controller {
    // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // Properties
    // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

    public readonly formatter = formatter;
    // ODATA_BLOCK_START
    protected odata: ODataService;
    // ODATA_BLOCK_END
    // FRAGMENT_BLOCK_START
    protected fragment: FragmentService;
    // FRAGMENT_BLOCK_END

    public override onInit() {
        // ODATA_BLOCK_START
        this.odata = new ODataService(this);
        // ODATA_BLOCK_END
        // FRAGMENT_BLOCK_START
        this.fragment = new FragmentService(this);
        // FRAGMENT_BLOCK_END
    }

    // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    // Utility Methods
    // ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────    

    public getComponent() {
        return this.getOwnerComponent() as Component;
    }

    public getCurrentView() {
        return this.getView() as View;
    }

    public getById<T extends UI5Element = UI5Element>(id: string) {
        const element = this.getCurrentView().byId(id);

        if (!element) {
            throw new Error("The UI5 Element with the following id was not found: " + id);
        }

        return element as T;
    }

    public getText(key: string, args?: any[]) {
        const model = this.getComponent().getModel("i18n");

        if (model instanceof ResourceModel === false) {
            throw new Error("The sap.ui.model.resource.ResourceModel instance was not found. Check your manifest.json and make sure you have the i18n model.");
        }

        const bundle = model.getResourceBundle() as ResourceBundle;
        return bundle.getText(key, args, false) as string;
    }

    public getRouter() {
        return this.getComponent().getRouter();
    }

    public getRoute(route: string) {
        return this.getRouter().getRoute(route) as Route;
    }

    public attachPatternMatched(route: string, handler: (event: Route$PatternMatchedEvent) => void) {
        this.getRoute(route).attachPatternMatched(handler, this);
    }

    public navTo(route: string, parameters?: Record<string, any>, replace?: boolean) {
        this.getRouter().navTo(route, parameters, replace);
    }

    public showBusy() {
        BusyIndicator.show(0);
    }

    public hideBusy() {
        BusyIndicator.hide();
    }

    public showError(message?: string) {
        MessageBox.error(message || this.getText("global.error.unexpected"), {
            contentWidth: "20%",
            styleClass: "customMessageBox"
        });
    }

    public showWarning(message: string) {
        MessageBox.warning(message, {
            contentWidth: "20%",
            styleClass: "customMessageBox"
        });
    }

    public showInformation(message: string) {
        MessageBox.information(message, {
            contentWidth: "20%",
            styleClass: "customMessageBox"
        });
    }

    public showConfirm(message: string, callback: Function) {
        MessageBox.confirm(message, {
            contentWidth: "20%",
            actions: ["OK", "CANCEL"],
            initialFocus: "CANCEL",
            emphasizedAction: "OK",
            styleClass: "customMessageBox",
            onClose: (event: "OK" | "CANCEL") => {
                if (event === "OK") {
                    callback.call(this);
                }
            }
        });
    }
}