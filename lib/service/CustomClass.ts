import consola from "consola";
import Manifest from "./Manifest";
import { confirm, input, select } from "@inquirer/prompts";
import path from "path";
import Util from "./Util";
import { mkdir, readFile, writeFile } from "fs/promises";

export default class CustomClass {
    private manifest = new Manifest();
    private name: string;
    private type: string;
    private extendBase: boolean;
    private appNamespace: string;
    private appBasePath: string;
    private className: string;
    private classNamespace: string;
    private classTypeBasePath: string;
    private module: string;
    private cancel = false;

    public async add() {
        await this.prompt();

        if (!this.cancel) {
            await this.run();
        }
    }

    private async prompt() {
        try {
            this.name = await this.getName();
            this.type = await this.getType();
            this.extendBase = await this.extendBaseClass();
        } catch (error) {
            this.cancel = true;

            if (error instanceof Error && error.name === "ExitPromptError") {
                consola.info("Custom Class generator has been canceled!");
            } else {
                throw error;
            }
        }
    }

    private async getName() {
        return input({
            message: "Enter a name for your custom class. Use dot notation for subfolders from the webapp folder:",
            required: true,
            validate: (value) => {
                const regex = /^([A-Za-z][A-Za-z0-9_]*)(\.[A-Za-z][A-Za-z0-9_]*)*$/;

                if (!regex.test(value)) {
                    return "Invalid class name. Use dot-separated parts starting with letters (e.g., lib.employee.NewEmployee).";
                }

                return true;
            }
        });
    }

    private async getType() {
        return select({
            message: "Select a type for your custom class (default: Final):",
            choices: [{
                name: "Abstract",
                value: "Abstract",
                description: "Abstract Class"
            }, {
                name: "Final",
                value: "Final",
                description: "Final Class"
            }],
            default: "Final"
        });
    }

    private async extendBaseClass() {
        return confirm({
            message: "Would you like to extend the built-in Base class (Base class is also generated if not exists)? (default: Y):",
            default: true
        });
    }

    private async run() {
        try {
            this.appNamespace = await this.manifest.getNamespace();
            this.appBasePath = this.manifest.getUI5Path(this.appNamespace);
            this.setClassLocations();

            consola.start("Generating a custom class...");

            await this.addCustomClassGlobalType();
            await this.addBaseController();

            if (this.extendBase) {
                await this.addBaseClass();
                await this.addBaseClassType();
            }

            await this.addCustomClass();
            await this.addCustomClassType();

            consola.success("UI5 Ultima has successfully generated the custom class!");
        } catch (error) {
            consola.error(error);
        }
    }

    private async addCustomClassGlobalType() {
        const targetDirectory = path.join(process.cwd(), "webapp", "types", "global");
        const targetPath = path.join(targetDirectory, "CustomClass.types.ts");
        const directoryExists = await Util.pathExists(targetDirectory);
        const exists = await Util.pathExists(targetPath);

        if (exists) {
            return;
        }

        const templatePath = path.join(__dirname, "..", "..", "template", "types", "global", "CustomClass.types.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating types/global directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating CustomClass.types.ts file...");
        await writeFile(targetPath, content);
    }

    private async addBaseController() {
        const targetDirectory = path.join(process.cwd(), "webapp", "controller");
        const targetPath = path.join(targetDirectory, "BaseController.ts");
        const exists = await Util.pathExists(targetPath);

        if (exists) {
            return;
        }

        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = path.join(__dirname, "..", "..", "template", "controller", "BaseController.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating controller directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating BaseController.ts file...");
        await writeFile(targetPath, content);
    }

    private setClassLocations() {
        const parts = this.name.split(".");

        this.classTypeBasePath = this.appBasePath + "/types";
        this.className = parts[parts.length - 1] as string;
        this.classNamespace = this.appNamespace;
        this.module = this.appBasePath + "/" + parts.join("/");

        if (parts.length > 1) {
            this.classNamespace = this.classNamespace + "." + parts.slice(0, -1).join(".");
        }

        if (parts.length > 2) {
            this.classTypeBasePath = this.classTypeBasePath + "/" + parts.slice(1, -1).join("/");
        }
    }

    private async addBaseClass() {
        const targetDirectory = path.join(process.cwd(), "webapp", "lib", "core");
        const targetPath = path.join(targetDirectory, "Base.ts");
        const exists = await Util.pathExists(targetPath);

        if (exists) {
            return;
        }

        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = path.join(__dirname, "..", "..", "template", "class", "core", "Base.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating lib/core directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating Base.ts file...");
        await writeFile(targetPath, content);
    }

    private async addBaseClassType() {
        const targetDirectory = path.join(process.cwd(), "webapp", "types", "core");
        const targetPath = path.join(targetDirectory, "Base.types.ts");
        const exists = await Util.pathExists(targetPath);

        if (exists) {
            return;
        }

        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = path.join(__dirname, "..", "..", "template", "types", "core", "Base.types.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating types/core directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating Base.types.ts file...");
        await writeFile(targetPath, content);
    }

    private async addCustomClass() {
        const targetDirectory = this.getTargetDirectoryForClass();
        const targetPath = path.join(targetDirectory, `${this.className}.ts`);
        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = this.getTemplatePathForClass();
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info(`Generating ${this.getRelativeTargetForClass()} directory...`);
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info(`Generating ${this.className}.ts file...`);
        await writeFile(targetPath, content);
    }

    private async addCustomClassType() {
        const targetDirectory = this.getTargetDirectoryForClassType();
        const targetPath = path.join(targetDirectory, `${this.className}.types.ts`);
        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = this.getTemplatePathForClassType();
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info(`Generating ${this.getRelativeTargetForClassType()} directory...`);
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info(`Generating ${this.className}.types.ts file...`);
        await writeFile(targetPath, content);
    }

    private getTargetDirectoryForClass() {
        const parts = this.name.split(".");
        let targetDirectory = path.join(process.cwd(), "webapp");

        if (parts.length > 1) {
            targetDirectory = path.join(targetDirectory, ...parts.slice(0, -1));
        }

        return targetDirectory;
    }

    private getRelativeTargetForClass() {
        const parts = this.name.split(".");
        let relativeTarget = "";

        if (parts.length > 1) {
            relativeTarget = parts.slice(0, -1).join("/");
        }

        return relativeTarget;
    }

    private getTargetDirectoryForClassType() {
        const parts = this.name.split(".");
        let targetDirectory = path.join(process.cwd(), "webapp", "types");

        if (parts.length > 2) {
            targetDirectory = path.join(targetDirectory, ...parts.slice(1, -1));
        }

        return targetDirectory;
    }

    private getRelativeTargetForClassType() {
        const parts = this.name.split(".");
        let relativeTarget = "";

        if (parts.length > 2) {
            relativeTarget = "types/" + parts.slice(1, -1).join("/");
        }

        return relativeTarget;
    }

    private getTemplatePathForClass() {
        const basePath = path.join(__dirname, "..", "..", "template", "class", "custom");

        if (this.type === "Final") {
            if (this.extendBase) {
                return path.join(basePath, "FinalWithBase.ts.tpl");
            } else {
                return path.join(basePath, "FinalNoBase.ts.tpl");
            }
        } else {
            if (this.extendBase) {
                return path.join(basePath, "AbstractWithBase.ts.tpl");
            } else {
                return path.join(basePath, "AbstractNoBase.ts.tpl");
            }
        }
    }

    private getTemplatePathForClassType() {
        const basePath = path.join(__dirname, "..", "..", "template", "types", "custom");

        if (this.extendBase) {
            return path.join(basePath, "ClassWithBase.types.ts.tpl");
        } else {
            return path.join(basePath, "ClassNoBase.types.ts.tpl");
        }
    }

    private replaceContent(rawContent: string) {
        return rawContent
            .replaceAll("{{APP_BASE_PATH}}", this.appBasePath)
            .replaceAll("{{CLASS_NAME}}", this.className)
            .replaceAll("{{CLASS_TYPE_PATH}}", this.classTypeBasePath + "/" + this.className)
            .replaceAll("{{CLASS_NAMESPACE}}", this.classNamespace)
            .replaceAll("{{MODULE}}", this.module)
            .replaceAll("{{NAMESPACE}}", this.appNamespace)
            .replaceAll("{{UI5_PATH}}", this.appBasePath);
    }
}