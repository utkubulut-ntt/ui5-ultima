import { confirm, input, select } from "@inquirer/prompts";
import { spawn } from "child_process";
import consola from "consola";
import { mkdir, readdir, readFile, writeFile } from "fs/promises";
import path from 'path';
import Manifest from "./Manifest";

export default class Generator {
    private manifest = new Manifest();
    private uiModule: string;
    private namespace: string;
    private version: string;
    private title: string;
    private description: string;
    private view: string;
    private model: boolean;
    private modelUri: string;
    private base: boolean;
    private odata: boolean;
    private fragment: boolean;
    private router: boolean;
    private ui5Path: string;
    private archive: string;
    private cancel = false;
    private npmTargets: { target: string; name: string }[] = [];

    public async generate() {
        await this.prompt();

        if (!this.cancel) {
            await this.generateApp();
            await this.generateApprouter();
            await this.installNpmPackages();
        }
    }

    private async generateApp() {
        const target = path.join(process.cwd(), this.uiModule);
        const source = path.join(__dirname, "..", "..", "template", "app");

        this.npmTargets.push({
            target: target,
            name: "UI application"
        });

        consola.start("Generating a free-style SAPUI5 application...");

        await this.createRootDirectory(target);
        await this.createFiles(source, target);

        consola.success("UI5 Ultima has successfully generated your application!");
    }

    private async generateApprouter() {
        if (!this.router) {
            return;
        }

        const target = path.join(process.cwd(), "router");
        const source = path.join(__dirname, "..", "..", "template", "router");
        
        this.npmTargets.push({
            target: target,
            name: "Approuter"
        });

        consola.start("Generating standalone approuter files...");

        await this.createRootDirectory(target);
        await this.createFiles(source, target);

        consola.success("UI5 Ultima has successfully generated your standalone approuter!");
    }

    private async createRootDirectory(target: string) {
        const directory = target.split("/");
        consola.info(`Generating ${directory[directory.length - 1]} root directory...`);
        await mkdir(target, { recursive: true });
    }

    private async createFiles(source: string, target: string) {
        const entries = await readdir(source, { withFileTypes: true });

        for (const entry of entries) {
            const sourcePath = path.join(source, entry.name);
            let targetName = entry.name;

            if (entry.isFile() && targetName.endsWith(".tpl")) {
                targetName = targetName.slice(0, -4);

                if (targetName.startsWith("Main.")) {
                    targetName = targetName.replace("Main.", `${this.view}.`);
                }
            }

            const targetPath = path.join(target, targetName);

            if (entry.isDirectory()) {
                if (!this.isIncluded(true, entry.name)) {
                    continue;
                }

                consola.info(`Generating ${entry.name} directory...`);
                await mkdir(targetPath, { recursive: true });
                await this.createFiles(sourcePath, targetPath);
            } else if (entry.isFile()) {
                if (!this.isIncluded(false, entry.name)) {
                    continue;
                }

                const rawContent = await readFile(sourcePath, "utf8");
                let content = this.replaceContent(rawContent, targetName);

                if (targetName === "manifest.json" && this.model) {
                    content = this.manifest.addODataModel(content, this.modelUri);
                }

                consola.info(`Generating ${targetName} file...`);
                await writeFile(targetPath, content, "utf-8");
            }
        }
    }

    private async prompt() {
        try {
            this.uiModule = await this.getUIModule();
            this.namespace = await this.getNamespace();
            this.version = await this.getVersion();
            this.title = await this.getTitle();
            this.description = await this.getDescription();
            this.view = await this.getView();
            this.model = await this.addODataModel();

            if (this.model) {
                this.modelUri = await this.getODataModelUri();
            }

            this.base = await this.includeBaseClass();
            this.odata = await this.includeODataClasses();
            this.fragment = await this.includeFragmentClass();
            this.router = await this.includeApprouter();
            this.ui5Path = this.namespace.replaceAll(".", "/");
            this.archive = this.namespace.replaceAll(".", "");
        } catch (error) {
            this.cancel = true;

            if (error instanceof Error && error.name === "ExitPromptError") {
                consola.info("Application generator has been canceled!");
            } else {
                throw error;
            }
        }
    }

    private async getUIModule() {
        return input({
            message: "Enter UI module name (UI5 Ultima will create a directory with the name you enter):",
            required: true,
            validate: (value) => {
                const regex = /^[a-z](?:[a-z0-9]*(?:-[a-z0-9]+)*)?$/;

                if (!regex.test(value)) {
                    return "Invalid module name. " +
                        "Must start with a lowercase letter, can contain numbers and single dashes, cannot end with a dash or have consecutive dashes.";
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

    private async getVersion() {
        const url = "https://raw.githubusercontent.com/hasanciftci26/ui5-ultima/sapui5-versions/versions.json";
        let versions: string[] = [];

        try {
            const response = await fetch(url);

            if (response.ok) {
                versions = await response.json();
            } else {
                versions.push("1.136.11");
            }
        } catch (err) {
            versions.push("1.136.11");
        }

        return select<string>({
            message: "Select SAPUI5 version:",
            choices: versions,
            default: "1.136.11"
        });
    }

    private async getTitle() {
        return input({
            message: "Enter a title for your SAPUI5 application:",
            required: true
        });
    }

    private async getDescription() {
        return input({
            message: "Enter a description for your SAPUI5 application:",
            required: true
        });
    }

    private async getView() {
        return input({
            message: "Enter a name for your initial SAPUI5 view (without .view.xml extension):",
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

    private async addODataModel() {
        return confirm({
            message: "Would you like to add an OData v2 data source? (default: Y):",
            default: true
        });
    }

    private async getODataModelUri() {
        return input({
            message: "Enter the URI of the OData v2 data source:",
            required: true
        });
    }

    private async includeBaseClass() {
        return confirm({
            message: "Would you like to include the Base class? (default: Y):",
            default: true
        });
    }

    private async includeODataClasses() {
        return confirm({
            message: "Would you like to include the OData classes? (default: Y):",
            default: true
        });
    }

    private async includeFragmentClass() {
        return confirm({
            message: "Would you like to include the FragmentService class? (default: Y):",
            default: true
        });
    }

    private async includeApprouter() {
        return confirm({
            message: "Would you like to include the Standalone Approuter? (default: Y):",
            default: true
        });
    }

    private isIncluded(directory: boolean, name: string) {
        if (directory) {
            if (name === "odata" && !this.odata) {
                return false;
            }

            if (name === "core" && !this.base && !this.fragment) {
                return false;
            }

            return true;
        } else {
            const baseClassFiles = ["Base.ts.tpl", "Base.types.ts.tpl"];
            const fragmentClassFiles = ["FragmentService.ts.tpl", "FragmentService.types.ts.tpl"];

            if (baseClassFiles.includes(name) && !this.base) {
                return false;
            }

            if (fragmentClassFiles.includes(name) && !this.fragment) {
                return false;
            }

            return true;
        }
    }

    private async installNpmPackages(): Promise<void> {
        const install = await confirm({
            message: "Would you like to install npm packages? (default: Y):",
            default: true
        });

        for (const npm of this.npmTargets) {
            if (install) {
                consola.info(`Installing ${npm.name} npm packages...`);
                await this.runNpmInstall(npm.target);
            }
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

    private replaceContent(rawContent: string, fileName: string) {
        const content = rawContent
            .replaceAll("{{UI_MODULE}}", this.uiModule)
            .replaceAll("{{NAMESPACE}}", this.namespace)
            .replaceAll("{{VERSION}}", this.version)
            .replaceAll("{{TITLE}}", this.title)
            .replaceAll("{{DESCRIPTION}}", this.description)
            .replaceAll("{{VIEW}}", this.view)
            .replaceAll("{{UI5_PATH}}", this.ui5Path)
            .replaceAll("{{ARCHIVE}}", this.archive)
            .replaceAll("{{WELCOME_FILE}}", this.archive)
            .replaceAll("{{DEFAULT_ROUTE}}", this.getDefaultRoute(false))
            .replaceAll("{{DEFAULT_UI_ROUTE}}", this.getDefaultRoute(true));

        return this.replaceBlocks(content, fileName);
    }

    private replaceBlocks(rawContent: string, fileName: string) {
        if (["BaseController.ts", "Base.ts", "Base.types.ts", "xs-app.json"].includes(fileName)) {
            return this.replaceBaseBlocks(rawContent);
        } else {
            return rawContent;
        }
    }

    private replaceBaseBlocks(rawContent: string) {
        if (!this.odata && !this.fragment) {
            return rawContent
                .replace(/^\s*\/\/ ODATA_BLOCK_START[\s\S]*?^\s*\/\/ ODATA_BLOCK_END[ \t]*\r?\n?/gm, "")
                .replace(/\/\/ ROUTE_BLOCK_START\s*\n\s*?\n?\/\/ ROUTE_BLOCK_END\s*\n?/g, "")
                .replace(/^\s*\/\/ FRAGMENT_BLOCK_START[\s\S]*?^\s*\/\/ FRAGMENT_BLOCK_END[ \t]*\r?\n?/gm, "");
        } else if (!this.odata) {
            return rawContent
                .replace(/^\s*\/\/ ODATA_BLOCK_START[\s\S]*?^\s*\/\/ ODATA_BLOCK_END[ \t]*\r?\n?/gm, "")
                .replace(/\/\/ ROUTE_BLOCK_START\s*\n\s*?\n?\/\/ ROUTE_BLOCK_END\s*\n?/g, "")
                .replace(/^[ \t]*\/\/ FRAGMENT_BLOCK_START[ \t]*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ FRAGMENT_BLOCK_END[ \t]*\r?\n?/gm, "");
        } else if (!this.fragment) {
            return rawContent
                .replace(/^\s*\/\/ FRAGMENT_BLOCK_START[\s\S]*?^\s*\/\/ FRAGMENT_BLOCK_END[ \t]*\r?\n?/gm, "")
                .replace(/^\s*\/\/ ROUTE_BLOCK_START.*\r?\n|^\s*\/\/ ROUTE_BLOCK_END.*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ ODATA_BLOCK_START[ \t]*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ ODATA_BLOCK_END[ \t]*\r?\n?/gm, "");
        } else {
            return rawContent
                .replace(/^[ \t]*\/\/ ODATA_BLOCK_START[ \t]*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ ODATA_BLOCK_END[ \t]*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ FRAGMENT_BLOCK_START[ \t]*\r?\n?/gm, "")
                .replace(/^[ \t]*\/\/ FRAGMENT_BLOCK_END[ \t]*\r?\n?/gm, "")
                .replace(/^\s*\/\/ ROUTE_BLOCK_START.*\r?\n|^\s*\/\/ ROUTE_BLOCK_END.*\r?\n?/gm, "");
        }
    }

    private getDefaultRoute(ui: boolean) {
        if (!this.model) {
            return "";
        }

        const modelUri = this.modelUri.endsWith('/') ? this.modelUri : this.modelUri + '/';

        return `{
            "source": "^${modelUri}(.*)$",
            "destination": "backend-api",
            "authenticationType": "xsuaa"
        }${ui ? "," : ""}`;
    }
}