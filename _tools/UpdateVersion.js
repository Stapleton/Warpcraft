const fs = require("node:fs");
const path = require("node:path");

const CurrentDate = new Date();

function ZeroPadding(input) {
    if (input.toString().length == 1) {
        return `0${input}`;
    }
    return input;
}

const DateVersion = `${CurrentDate.getFullYear()}/${ZeroPadding(CurrentDate.getMonth() + 1)}/${ZeroPadding(
    CurrentDate.getDate()
)}-${ZeroPadding(CurrentDate.getHours())}:${ZeroPadding(CurrentDate.getMinutes())}`;

const BetterCompatibilityCheckerConfig = {
    projectID: 58139301,
    modpackName: "smclt",
    modpackVersion: DateVersion,
    useMetadata: false,
};

fs.writeFileSync(path.relative(process.cwd(), "../config/bcc.json"), JSON.stringify(BetterCompatibilityCheckerConfig));
