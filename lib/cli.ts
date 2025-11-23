#!/usr/bin/env node

import { program } from "commander";
import generate from "./command/generate";
import addView from "./command/add-view";

program
    .name("ui5-ultima")
    .version("1.0.0")
    .description(
        "UI5 Ultima is a CLI tool to generate free-style SAPUI5 applications and artifacts with TypeScript. " +
        "The UI5 Ultima comes with some useful built-in SAPUI5 classes."
    );

program
    .addCommand(generate)
    .addCommand(addView);

program.parse();