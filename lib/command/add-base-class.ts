import { Command } from "commander";
import BaseClass from "../service/BaseClass";

export default new Command("add-base-class")
    .description(
        "Adds the built-in UI5 Ultima Base class extending the ManagedObject class. The Base class is generated in the webapp/lib/core directory."
    )
    .action(async () => {
        const base = new BaseClass();
        await base.add();
    });