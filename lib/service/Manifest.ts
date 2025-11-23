import { readFile } from "fs/promises";
import path from "path";
import { ManifestContent } from "../types/Manifest.types";

export default class Manifest {
    public getContent() {
        return this.parse();
    }

    public async getNamespace() {
        const content = await this.parse();

        if (!content["sap.app"]?.id) {
            throw new Error(
                "The namespace of the application was not found. " +
                "Make sure you have \"sap.app\": {\"id\": \"my.app.namespace\"} section in your application's manifest.json file."
            );
        }

        return content["sap.app"].id;
    }

    public getUI5Path(namespace: string) {
        return namespace.replaceAll(".", "/");
    }

    private async parse() {
        const file = await this.load();

        try {
            const content = JSON.parse(file) as ManifestContent;
            return content;
        } catch (error) {
            throw new Error("The manifest.json file was found but could not be parsed. The content inside the file could be incompatible with JSON format.");
        }
    }

    private async load() {
        const manifestPath = path.join(process.cwd(), "webapp", "manifest.json");

        try {
            const file = await readFile(manifestPath, "utf-8");
            return file;
        } catch (error) {
            if (this.hasCode(error) && error.code === "ENOENT") {
                throw new Error(
                    "The manifest.json file was not found. Run the add-view command in your UI module directory containing the webapp directory. " +
                    "The manifest.json file must be inside of the webapp directory."
                );
            } else {
                throw error;
            }
        }
    }

    private hasCode(error: any): error is { code: string; } {
        return error instanceof Error && "code" in error;
    }
}