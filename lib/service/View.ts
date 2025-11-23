import consola from "consola";
import Manifest from "./Manifest";
import { input } from "@inquirer/prompts";
import path from "path";
import { mkdir, readFile, writeFile } from "fs/promises";
import Util from "./Util";

export default class View {
    private manifest = new Manifest();
    private view: string;
    private pattern: string;
    private namespace: string;
    private ui5Path: string;
    private cancel = false;

    public async add() {
        await this.prompt();

        if (!this.cancel) {
            await this.addView();
        }
    }

    private async prompt() {
        try {
            this.view = await this.getView();
            this.pattern = await this.getPattern();
        } catch (error) {
            this.cancel = true;

            if (error instanceof Error && error.name === "ExitPromptError") {
                consola.info("View generator has been canceled!");
            } else {
                throw error;
            }
        }
    }

    private async getView() {
        return input({
            message: "Enter a name for your SAPUI5 view (without .view.xml extension):",
            required: true,
            validate: (value) => {
                const regex = /^[A-Z][a-zA-Z0-9]*$/;

                if (!regex.test(value)) {
                    return "Invalid view name. Must start with an uppercase letter and contain only letters and numbers.";
                }

                return true;
            }
        });
    }

    private async getPattern() {
        return input({
            message: "Enter a pattern for the route to be created in your application's manifest.json file:",
            default: ""
        });
    }

    private async addView() {
        try {
            this.namespace = await this.manifest.getNamespace();
            this.ui5Path = this.manifest.getUI5Path(this.namespace);

            consola.start("Generating the SAPUI5 view...");

            await this.createViewFile();
            await this.createControllerFile();
            await this.manifest.addRoute(this.view, this.pattern);

            consola.success("UI5 Ultima has successfully generated the SAPUI5 View with Controller and manifest.json has been updated with the new route!");
        } catch (error) {
            consola.error(error);
        }
    }

    private async createViewFile() {
        const fileName = `${this.view}.view.xml`;
        const targetDirectory = path.join(process.cwd(), "webapp", "view");
        const target = path.join(targetDirectory, fileName);
        const templatePath = path.join(__dirname, "..", "..", "template", "view", "Template.view.xml.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        consola.info(`Generating ${fileName} file...`);
        await mkdir(targetDirectory, { recursive: true });
        await writeFile(target, content);
    }

    private async createControllerFile() {
        const fileName = `${this.view}.controller.ts`;
        const targetDirectory = path.join(process.cwd(), "webapp", "controller");
        const target = path.join(targetDirectory, fileName);
        const templatePath = path.join(__dirname, "..", "..", "template", "controller", "Template.controller.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        consola.info(`Generating ${fileName} file...`);

        await mkdir(targetDirectory, { recursive: true });
        await this.createBaseControllerFile();
        await writeFile(target, content);
    }

    private async createBaseControllerFile() {
        const target = path.join(process.cwd(), "webapp", "controller", "BaseController.ts");
        const exists = await Util.pathExists(target);

        if (!exists) {
            const templatePath = path.join(__dirname, "..", "..", "template", "controller", "BaseController.ts.tpl");
            const template = await readFile(templatePath, "utf-8");
            const content = this.replaceContent(template);

            consola.info("The BaseController.ts file is missing and being generated...");
            await writeFile(target, content);
        }
    }

    private replaceContent(rawContent: string) {
        return rawContent
            .replaceAll("{{NAMESPACE}}", this.namespace)
            .replaceAll("{{VIEW}}", this.view)
            .replaceAll("{{UI5_PATH}}", this.ui5Path);
    }
}