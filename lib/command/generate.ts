import { Command } from "commander";
import Generator from "../service/Generator";

export default new Command("generate")
    .description("Generates a free-style SAPUI5 application with TypeScript.")
    .action(async () => {
        const generator = new Generator();
        await generator.generate();
    });