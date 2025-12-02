import { Command } from "commander";
import Util from "../service/Util";
import ApprouterService from "../service/ApprouterService";


export default new Command("add-approuter")
    .description(Util.getCommandDescription(
        "Adds the standalone Approuter files. Router files are generated in the router directory.\n" +
        "WARNING: This action overrides router related files if already exist!"
    ))
    .action(async () => {
        const router = new ApprouterService();
        await router.add();
    });