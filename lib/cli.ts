#!/usr/bin/env node

import { program } from "commander";
import generate from "./command/generate";

program
    .name("ui5-ultima")
    .version("1.0.0")
    .description(
        "UI5 Ultima is a CLI tool to generate free-style SAPUI5 applications with TypeScript. The UI5 Ultima comes with some useful built-in SAPUI5 classes."
    );

program
    .addCommand(generate);

program.parse();