{
    "compilerOptions": {
        "target": "ESNext",
        "module": "ESNext",
        "strict": true,
        "noImplicitOverride": true,
        "noUnusedLocals": true,
        "noUnusedParameters": true,
        "noFallthroughCasesInSwitch": true,
        "noUncheckedIndexedAccess": true,
        "skipLibCheck": true,
        "noEmitOnError": true,
        "useUnknownInCatchVariables": true,
        "noImplicitThis": true,
        "noImplicitAny": false,
        "allowJs": false,
        "sourceMap": false,
        "inlineSourceMap": false,
        "strictPropertyInitialization": false,
        "baseUrl": "./",
        "rootDir": "./webapp",
        "outDir": "./dist",
        "paths": {
            "{{UI5_PATH}}/*": [
                "./webapp/*"
            ]
        },
        "types": [
            "@sapui5/types"
        ]
    },
    "include": [
        "webapp"
    ]
}