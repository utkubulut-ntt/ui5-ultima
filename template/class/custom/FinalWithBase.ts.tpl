import BaseController from "{{APP_BASE_PATH}}/controller/BaseController";
import Base from "{{APP_BASE_PATH}}/lib/core/Base";
import { ClassMetadata } from "{{APP_BASE_PATH}}/types/global/CustomClass.types";
import { {{CLASS_NAME}}Settings } from "{{CLASS_TYPE_PATH}}.types";

/**
 * @namespace {{CLASS_NAMESPACE}}
 */
export default class {{CLASS_NAME}} extends Base {
    public static override readonly metadata: ClassMetadata = {
        final: true
    };

    constructor(controller: BaseController, settings?: {{CLASS_NAME}}Settings) {
        super(controller, settings);
    }
}