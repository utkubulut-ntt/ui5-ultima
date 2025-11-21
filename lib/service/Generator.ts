import { confirm, input } from "@inquirer/prompts";
import { spawn } from "child_process";
import { mkdir, readdir, readFile, writeFile } from "fs/promises";
import path from 'path';

export default class Generator {
    private uiModule: string;
    private namespace: string;
    private version: string;
    private title: string;
    private description: string;
    private view: string;
    private base: boolean;
    private odata: boolean;
    private fragment: boolean;
    private ui5Path: string;
    private archive: string;

    public async generate() {
        await this.prompt();
        await this.generateApp();
    }

    private async generateApp() {
        const target = path.join(process.cwd(), this.uiModule);
        const source = path.join(__dirname, "..", "..", "template", "app");
        await this.createRootDirectory(target);
        await this.createFiles(source, target);
        await this.installNpmPackages(target);
    }

    private async createRootDirectory(target: string) {
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

                await mkdir(targetPath, { recursive: true });
                await this.createFiles(sourcePath, targetPath);
            } else if (entry.isFile()) {
                if (!this.isIncluded(false, entry.name)) {
                    continue;
                }

                const rawContent = await readFile(sourcePath, "utf8");
                const content = this.replaceContent(rawContent);
                await writeFile(targetPath, content, "utf-8");
            }
        }
    }

    private async prompt() {
        this.uiModule = await this.getUIModule();
        this.namespace = await this.getNamespace();
        this.version = await this.getVersion();
        this.title = await this.getTitle();
        this.description = await this.getDescription();
        this.view = await this.getView();
        this.base = await this.includeBaseClass();
        this.odata = await this.includeODataClasses();
        this.fragment = await this.includeFragmentClass();
        this.ui5Path = this.namespace.replaceAll(".", "/");
        this.archive = this.namespace.replaceAll(".", "");
    }

    private async getUIModule() {
        return input({
            message: "Enter UI module name",
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
            message: "Enter a namespace",
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
        return "1.136.11";
    }

    private async getTitle() {
        return input({
            message: "Enter your SAPUI5 app title",
            required: true
        });
    }

    private async getDescription() {
        return input({
            message: "Enter your SAPUI5 app description",
            required: true
        });
    }

    private async getView() {
        return input({
            message: "Enter the initial view name",
            validate: (value) => {
                const regex = /^[A-Z][a-zA-Z]*$/;

                if (!regex.test(value)) {
                    return "Invalid View name. Must start with an uppercase letter and contain only letters.";
                }

                return true;
            }
        });
    }

    private async includeBaseClass() {
        return confirm({
            message: "Would you like to include the Base class? (default: Y)",
            default: true
        });
    }

    private async includeODataClasses() {
        return confirm({
            message: "Would you like to include the OData classes? (default: Y)",
            default: true
        });
    }

    private async includeFragmentClass() {
        return confirm({
            message: "Would you like to include the Fragment class? (default: Y)",
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

    private installNpmPackages(target: string): Promise<void> {
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

    private replaceContent(content: string) {
        return content
            .replaceAll("{{UI_MODULE}}", this.uiModule)
            .replaceAll("{{NAMESPACE}}", this.namespace)
            .replaceAll("{{VERSION}}", this.version)
            .replaceAll("{{TITLE}}", this.title)
            .replaceAll("{{DESCRIPTION}}", this.description)
            .replaceAll("{{VIEW}}", this.view)
            .replaceAll("{{UI5_PATH}}", this.ui5Path)
            .replaceAll("{{ARCHIVE}}", this.archive);
    }
}