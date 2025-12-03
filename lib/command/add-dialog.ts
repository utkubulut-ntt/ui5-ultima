import { Command } from "commander";
import Dialog from "../service/Dialog";
import Util from "../service/Util";

export default new Command("add-dialog")
    .description(Util.getCommandDescription(
        "Adds a new XML fragment with a Dialog to your project. \n" +
        "The fragment name can include a relative path from the webapp folder.\n" +
        "For example, 'fragments.employee.NewEmployee' will create: 'webapp/fragments/employee/NewEmployee.fragment.xml'\n" +
        "WARNING: This action overrides the fragment file if already exists in the specified directory."
    ))
    .action(async () => {
        const dialog = new Dialog();
        await dialog.add();
    });