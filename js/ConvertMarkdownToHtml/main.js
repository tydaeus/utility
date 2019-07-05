const path = require('path');
const fs = require('fs');
const config = require('./config');
const markdown = require('./markdown');
const css = require('./css');

config.processArgs();

config.files.forEach((file) => {
    convertMarkdownFile(file, file + '.html');
});

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

