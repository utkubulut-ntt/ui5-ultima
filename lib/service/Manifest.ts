import { readFile, writeFile } from "fs/promises";
import path from "path";
import { ManifestContent, Route, Target, TemplateManifestContent } from "../types/Manifest.types";
import Util from "./Util";

export default class Manifest {
    public async check() {
        const manifestPath = path.join(process.cwd(), "webapp", "manifest.json");
        const exists = await Util.pathExists(manifestPath);

        if (!exists) {
            throw new Error(
                "The manifest.json file was not found. Run the command in your UI module directory containing the webapp directory. " +
                "The manifest.json file must be inside of the webapp directory."
            );
        }
    }

    public addODataModel(rawContent: string, uri: string) {
        const content = JSON.parse(rawContent) as TemplateManifestContent;

        content["sap.app"].dataSources = {
            mainService: {
                uri: uri,
                type: "OData",
                settings: {
                    odataVersion: "2.0"
                }
            }
        };

        content["sap.ui5"].models[""] = {
            dataSource: "mainService",
            preload: true,
            settings: {
                defaultBindingMode: "TwoWay",
                defaultCountMode: "Inline"
            }
        };

        return JSON.stringify(content, null, 4);
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

    public async addRoute(view: string, pattern: string) {
        const manifestPath = path.join(process.cwd(), "webapp", "manifest.json");
        const content = await this.parse();
        const targetName = `Target${view}`;
        const route: Route = {
            name: `Route${view}`,
            pattern: pattern,
            target: [targetName]
        };
        const target: Target = {
            id: view,
            name: view,
            type: "View",
            viewType: "XML",
            transition: "slide",
            clearControlAggregation: false
        };
        const targets: Record<string, Target> = { [targetName]: target };

        if (content["sap.ui5"]) {
            if (content["sap.ui5"].routing) {
                if (content["sap.ui5"].routing.routes) {
                    content["sap.ui5"].routing.routes.push(route);
                } else {
                    content["sap.ui5"].routing.routes = [route];
                }

                if (content["sap.ui5"].routing.targets) {
                    content["sap.ui5"].routing.targets[targetName] = target;
                } else {
                    content["sap.ui5"].routing.targets = targets;
                }
            } else {
                content["sap.ui5"].routing = {
                    routes: [route],
                    targets: targets
                };
            }
        } else {
            content["sap.ui5"] = {
                routing: {
                    routes: [route],
                    targets: targets
                }
            };
        }

        await writeFile(manifestPath, JSON.stringify(content, null, 4));
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
                    "The manifest.json file was not found. Run the command in your UI module directory containing the webapp directory. " +
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