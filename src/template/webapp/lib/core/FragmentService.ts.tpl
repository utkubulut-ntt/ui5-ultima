import Dialog from "sap/m/Dialog";
import ManagedObject from "sap/ui/base/ManagedObject";
import Control from "sap/ui/core/Control";
import Fragment from "sap/ui/core/Fragment";
import Context from "sap/ui/model/odata/v2/Context";
import ODataModel from "sap/ui/model/odata/v2/ODataModel";
import BaseController from "{{UI5_PATH}}/controller/BaseController";
import { DialogEscapeEvent, FragmentServiceSettings, OpenDialogSettings } from "{{UI5_PATH}}/types/core/FragmentService.types";
import { ClassMetadata } from "{{UI5_PATH}}/types/global/CustomClass.types";

/**
 * @namespace {{NAMESPACE}}.lib.core
 */
export default class FragmentService extends ManagedObject {
    public static readonly metadata: ClassMetadata = {
        final: true,
        properties: {
            basePath: { type: "string", defaultValue: "{{NAMESPACE}}.fragments" }
        }
    };
    private readonly controller: BaseController;
    private content?: Control | Control[];
    private context?: Context;
    private resetContextOnClose?: boolean;

    constructor(controller: BaseController, settings?: FragmentServiceSettings) {
        super(settings);
        this.controller = controller;
    }

    public async load<T extends Control | Control[] = Control | Control[]>(path: string) {
        const content = await Fragment.load({
            id: this.controller.getCurrentView().getId(),
            controller: this.controller,
            name: this.getFullPath(path)
        });

        this.content = content;
        return this.content as T;
    }

    public getContent<T extends Control | Control[] = Control | Control[]>() {
        if (!this.content) {
            throw new Error("No fragment content was loaded. Please use load() or openDialog() method to load the fragment content.");
        }

        return this.content as T;
    }

    public async openDialog(path: string, settings?: OpenDialogSettings) {
        const dialog = await this.load(path);

        if (dialog instanceof Dialog === false) {
            throw new Error("The sap.m.Dialog instance was not found in the loaded fragment. Please make sure the root control in your fragment is a Dialog.");
        }

        this.context = settings?.context;
        this.resetContextOnClose = settings?.resetContextOnClose;
        this.controller.getCurrentView().removeDependent(dialog);
        this.controller.getCurrentView().addDependent(dialog);

        if (settings?.context) {
            dialog.setBindingContext(settings.context);
        }

        if (settings?.handleEscape) {
            dialog.setEscapeHandler(this.onEscape.bind(this));
        }

        if (settings?.title) {
            dialog.setTitle(settings.title);
        }

        dialog.open();
        return dialog;
    }

    public closeDialog() {
        try {
            const dialog = this.getContent();

            if (dialog instanceof Dialog && dialog.isOpen()) {
                dialog.close();
                dialog.destroy();
                this.resetContexts();
            }
        } catch (error) {
            throw new Error("No sap.m.Dialog instance to be closed was found. Please first use openDialog() method to open an sap.m.Dialog instance.");
        }
    }

    public destroyContent() {
        const content = this.content;

        if (content) {
            if (Array.isArray(content)) {
                content.forEach((cont) => {
                    this.controller.getCurrentView().removeDependent(cont);
                    cont.destroy();
                });
            } else {
                this.controller.getCurrentView().removeDependent(content);
                content.destroy();
            }
        }
    }

    private onEscape(event: DialogEscapeEvent) {
        event.reject();
        this.closeDialog();
    }

    private resetContexts() {
        if (this.context && this.resetContextOnClose) {
            const model = this.context.getModel() as ODataModel;
            model.resetChanges([this.context.getPath()], true, true);
        }
    }

    private getFullPath(path: string) {
        if (path.startsWith(this.getBasePath())) {
            return path;
        }

        return this.getBasePath() + "." + path;
    }
}