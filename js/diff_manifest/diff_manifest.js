const fs = require('fs');
const args = process.argv.slice(2);
const scriptName = process.argv[1];

function displayUsage() {
    console.log("Usage:");
    console.log("  " + scriptName + " LEFT_MANIFEST RIGHT_MANIFEST");
}

if (args.length !== 2) {
    console.error("ERROR: Invalid Usage");
    displayUsage();
    process.exit(1);
}

function attemptRead(filePath) {
    let result;

    try {
        result = fs.readFileSync(filePath, {encoding: "UTF-8"})
    } catch (e) {
        console.error('ERROR: Failed to read file "' + filePath + "'");
        console.error(e);
        process.exit(1);
    }

    return result;
}

function sanitizeJSON(jsonString) {
    return jsonString.replace(/,\s*}/g, "}").replace(/,\s*]/g, "]");
}

function attemptParse(str, name) {
    let result;

    try {
        result = JSON.parse(sanitizeJSON(str));
    } catch (e) {
        console.error("ERROR: Failed to parse " + name + ":");
        console.error(e);
        process.exit(1);
    }

    return result;
}

function verifyFileFormat(obj, name) {
    if (!obj.files) {
        console.error("ERROR: " + name + " contains no file data");
        process.exit(1);
    }

    if (!(obj.files instanceof Array)) {
        console.error("ERROR: " + name + " file data is not array");
        process.exit(1);
    }
}

function mapFiles(files) {
    const map = new Map();

    files.forEach(val => {
        if (!val.name) {
            console.warn("WARN: file entry is unnamed:", val);
        } else {
            map.set(val.name, val);
        }
    });

    return map;
}

const leftManifest = attemptRead(args[0]);
const rightManifest = attemptRead(args[1]);

const leftObj = attemptParse(leftManifest, "left manifest");
const rightObj = attemptParse(rightManifest, "right manifest");

verifyFileFormat(leftObj, "left manifest");
verifyFileFormat(rightObj, "right manifest");

const leftFiles = leftObj.files;
const rightFiles = rightObj.files;

const leftMap = mapFiles(leftFiles);
const rightMap = mapFiles(rightFiles);

for (let [key, leftFile] of leftMap) {
    let rightFile = rightMap.get(key);

    if (rightFile) {
        if (leftFile.md5 === rightFile.md5) {
            // console.info(key + " md5 match");
        } else {
            console.log(key + " md5 MISMATCH");
        }
        rightMap.delete(key);
    } else {
        console.log(key + " NOT FOUND in right file");
    }
}

for (let [key, rightFile] of rightMap) {
    console.log(key + " NOT FOUND in left file");
}





