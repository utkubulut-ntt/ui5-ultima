import consola from "consola";
import path from "path";
import Util from "./Util";
import { mkdir, readdir, readFile, writeFile } from "fs/promises";
import { confirm, input } from "@inquirer/prompts";
import { spawn } from "child_process";
import Manifest from "./Manifest";

export default class ApprouterService {
    private uiPath: string;
    private namespace: string;
    private modelUri: string;
    private cancel = false;

    public async add() {
        await this.prompt();

        if (!this.cancel) {
            consola.start("Generating the Standalone Approuter...");
            await this.generateRouter();
            consola.success("UI5 Ultima has successfully generated the Standalone Approuter!");
        }
    }

    private async generateRouter() {
        const targetDirectory = path.join(process.cwd(), "router");
        const directoryExists = await Util.pathExists(targetDirectory);
        const templateDirectory = path.join(__dirname, "..", "..", "template", "router");
        const templates = await readdir(templateDirectory);

        if (!directoryExists) {
            consola.info("Generating lib/odata directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        for (const template of templates) {
            const templatePath = path.join(templateDirectory, template);
            const fileName = template.slice(0, -4);
            const targetPath = path.join(targetDirectory, fileName);
            const rawContent = await readFile(templatePath, "utf-8");
            const content = this.replaceContent(rawContent);

            consola.info(`Generating ${fileName} file...`);
            await writeFile(targetPath, content);
        }

        await this.installNpmPackages(targetDirectory);
    }

    private replaceContent(rawContent: string) {
        return rawContent
            .replaceAll("{{UI_MODULE}}", this.uiPath)
            .replaceAll("{{WELCOME_FILE}}", this.getWelcomeFile())
            .replaceAll("{{DEFAULT_ROUTE}}", this.getDefaultRoute());
    }

    private async prompt() {
        try {
            this.uiPath = await this.getUIPath();

            if (!await this.checkManifestFile()) {
                if (!this.namespace) {
                    this.namespace = await this.getNamespace();
                }
                
                this.modelUri = await this.getModelUri();
            }
        } catch (error) {
            this.cancel = true;

            if (error instanceof Error && error.name === "ExitPromptError") {
                consola.info("Approuter generator has been canceled!");
            } else {
                throw error;
            }
        }
    }

    private async getUIPath() {
        return input({
            message: "Please provide the path where the UI module is located or will be located, relative to the folder where you run the command (Do not start with '/'):",
            required: true,
            validate: (value) => {
                const regex = /^[^/].*$/;

                if (!regex.test(value)) {
                    return "Invalid path. " +
                        "Can not start with '/'.";
                }

                return true;
            }
        });
    }

    private async getNamespace() {
        return input({
            message: "Enter SAPUI5 app namespace:",
            required: true,
            validate: (value) => {
                const regex = /^[a-z](?:[a-z0-9]*(?:\.[a-z0-9]+)*)?$/;

                if (!regex.test(value)) {
                    return "Invalid namespace. " +
                        "Must start with a lowercase letter, can contain numbers and single dots, and cannot end with a dot or have consecutive dots.";
                }

                return true;
            }
        });
    }

    private getWelcomeFile() {
        return this.namespace.replaceAll(".", "");
    }

    private getDefaultRoute() {
        if (!this.modelUri) {
            return "";
        }

        const modelUri = this.modelUri.endsWith('/') ? this.modelUri : this.modelUri + '/';
        
        return `{
            "source": "^${modelUri}(.*)$",
            "destination": "backend-api",
            "authenticationType": "xsuaa"
        }`;
    }

    private async getModelUri() {
        return input({
            message: "Enter the URI of the OData v2 data source (You can pass empty if you don't have any):",
            required: false
        });
    }

    private async installNpmPackages(target: string): Promise<void> {
        const install = await confirm({
            message: "Would you like to install npm packages? (default: Y):",
            default: true
        });

        if (install) {
            consola.info("Installing npm packages...");
            await this.runNpmInstall(target);
        }
    }

    private runNpmInstall(target: string): Promise<void> {
        return new Promise((resolve, reject) => {
            const child = spawn("npm", ["install"], {
                cwd: target,
                stdio: "inherit",
                shell: true
            });

            child.on("close", (code) => {
                if (code !== 0) {
                    return reject(new Error(`npm install exited with ${code}`))
                };

                resolve();
            });
        });
    }

    private async checkManifestFile() {
        const manifest = new Manifest(this.uiPath);

        try {
            await manifest.check();
            this.namespace = await manifest.getNamespace();
            this.modelUri = await manifest.getModelUri();
        }
        catch (err){
            return false;
        }

        return true;
    }
}