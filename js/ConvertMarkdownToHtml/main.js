const path = require('path');
const fs = require('fs');
const config = require('./config');
const markdown = require('./markdown');
const css = require('./css');

config.processArgs();

if (config.files.length < 1) {
    console.error('ERR: no files specified for conversion');
}

config.files.forEach((file) => {
    processArgument(file);
});

function processArgument(file) {
    if (!fs.existsSync(file)) {
        console.error('ERR: file "' + file + '" not found. Skipping.');
        return;
    }

    let stats = fs.statSync(file);

    if (stats.isDirectory()) {
        processDir(file);
        return;
    }

    if (path.extname(file) !== '.md') {
        console.info('File "' + file + '" is not a .md file. Skipping.');
        return;
    }

    convertMarkdownFile(file, file + '.html');
}

function processDir(dir) {
    let files = fs.readdirSync(dir);

    files.forEach((file) => {
        let filePath = path.join(dir, file);

        // skip subdirs unless recurse is on
        if (config.options.recurse || fs.statSync(filePath).isFile()) {
            processArgument(filePath);
        }
    });
}

function convertMarkdownFile(inputFile, outputFile) {
    console.info('Reading markdown from "' + inputFile + '"');

    let inputContent = fs.readFileSync(inputFile, {encoding: 'utf8'});

    let outputBody = markdown.convert(inputContent);

    let cssEmbeddedTag = css.getCssStyleSheetAsEmbeddedTag();

    let cssCustomizationTag = css.getCssCustomizationTag();

    // create header
    let outputHeader =
        cssEmbeddedTag +
        cssCustomizationTag +
        '<div class="markdown-body">\n';

    // create footer
    let outputFooter = '</div>\n';


    let outputContent = outputHeader + outputBody + outputFooter;


    fs.writeFileSync(outputFile, outputContent);
    console.info('Html written to "' + outputFile + "'");
}

