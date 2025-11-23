import { Command } from "commander";
import View from "../service/View";

export default new Command("add-view")
    .description(
        "Adds a new SAPUI5 view (xml) with controller (ts). Additionally, it adds a new route and target to the manifest.json file. " +
        "Run this command in the UI module directory containing the webapp directory."
    )
    .action(async () => {
        const view = new View();
        await view.add();
    });