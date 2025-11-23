import consola from "consola";
import Manifest from "./Manifest";
import { input } from "@inquirer/prompts";
import path from "path";
import { mkdir, readFile, writeFile } from "fs/promises";
import Util from "./Util";

export default class Fragment {
    private manifest = new Manifest();
    private name: string;
    private cancel = false;

    public async add() {
        await this.prompt();

        if (!this.cancel) {
            await this.addFragment();
        }
    }

    private async prompt() {
        try {
            this.name = await this.getName();
        } catch (error) {
            this.cancel = true;

            if (error instanceof Error && error.name === "ExitPromptError") {
                consola.info("Fragment generator has been canceled!");
            } else {
                throw error;
            }
        }
    }

    private async getName() {
        return input({
            message: "Enter a name for your SAPUI5 XML fragment (without .fragment.xml). Use dot notation for subfolders from the webapp folder:",
            required: true,
            validate: (value) => {
                const regex = /^([A-Za-z][A-Za-z0-9_]*)(\.[A-Za-z][A-Za-z0-9_]*)*$/;

                if (!regex.test(value)) {
                    return "Invalid fragment name. Use dot-separated parts starting with letters (e.g., fragments.employee.NewEmployee).";
                }

                return true;
            }
        });
    }

    private async addFragment() {
        try {
            await this.manifest.check();
            consola.start("Generating the SAPUI5 XML fragment...");

            const parts = this.name.split(".");
            const fragmentName = `${parts[parts.length - 1]}.fragment.xml`;
            let targetDirectory = path.join(process.cwd(), "webapp");

            if (parts.length > 1) {
                targetDirectory = path.join(targetDirectory, ...parts.slice(0, -1));
                const exists = await Util.pathExists(targetDirectory);

                if (!exists) {
                    consola.info(`Generating ${parts.slice(0, -1).join("/")} directory...`);
                    await mkdir(targetDirectory, { recursive: true });
                }
            }

            const target = path.join(targetDirectory, fragmentName);
            const templatePath = path.join(__dirname, "..", "..", "template", "fragment", "Template.fragment.xml.tpl");
            const template = await readFile(templatePath, "utf-8");

            consola.info(`Generating ${fragmentName} file...`);
            await writeFile(target, template);
            consola.success("UI5 Ultima has successfully generated the SAPUI5 XML fragment file!");
        } catch (error) {
            consola.error(error);
        }
    }
}