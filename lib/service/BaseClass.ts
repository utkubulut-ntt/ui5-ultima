import consola from "consola";
import Manifest from "./Manifest";
import path from "path";
import { mkdir, readFile, writeFile } from "fs/promises";
import Util from "./Util";

export default class BaseClass {
    private manifest = new Manifest();
    private namespace: string;
    private ui5Path: string;

    public async add() {
        try {
            this.namespace = await this.manifest.getNamespace();
            this.ui5Path = this.manifest.getUI5Path(this.namespace);

            consola.start("Generating the Base class...");

            await this.addBaseClass();
            await this.addBaseClassType();
            await this.addCustomClassType();

            consola.success("UI5 Ultima has successfully generated the Base class!");
        } catch (error) {
            consola.error(error);
        }
    }

    private async addBaseClass() {
        const targetDirectory = path.join(process.cwd(), "webapp", "lib", "core");
        const targetPath = path.join(targetDirectory, "Base.ts");
        const classExists = await Util.pathExists(targetPath);
        const directoryExists = await Util.pathExists(targetDirectory);

        if (classExists) {
            throw new Error("The Base class already exists in the following path: " + targetDirectory);
        }

        const templatePath = path.join(__dirname, "..", "..", "template", "class", "Base.ts.tpl");
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
        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = path.join(__dirname, "..", "..", "template", "types", "Base.types.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating types/core directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating Base.types.ts file...");
        await writeFile(targetPath, content);
    }

    private async addCustomClassType() {
        const targetDirectory = path.join(process.cwd(), "webapp", "types", "global");
        const targetPath = path.join(targetDirectory, "CustomClass.types.ts");
        const directoryExists = await Util.pathExists(targetDirectory);
        const templatePath = path.join(__dirname, "..", "..", "template", "types", "CustomClass.types.ts.tpl");
        const template = await readFile(templatePath, "utf-8");
        const content = this.replaceContent(template);

        if (!directoryExists) {
            consola.info("Generating types/global directory...");
            await mkdir(targetDirectory, { recursive: true });
        }

        consola.info("Generating CustomClass.types.ts file...");
        await writeFile(targetPath, content);
    }

    private replaceContent(rawContent: string) {
        return rawContent
            .replaceAll("{{NAMESPACE}}", this.namespace)
            .replaceAll("{{UI5_PATH}}", this.ui5Path);
    }
}