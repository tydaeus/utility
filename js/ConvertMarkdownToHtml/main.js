const commonmark = require('commonmark');
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

    // read css file
    // FUTURE: allow specifying alternative css file
    // FUTURE: allow linking css file instead of embedding?
    let cssEmbeddedTag = css.getCssStyleSheetAsEmbeddedTag();

    // create header
    let outputHeader =
        cssEmbeddedTag +
        '<style>\n' +
        '.markdown-body { \n' +
        '    box-sizing: border-box; \n' +
        '    min-width: 200px; \n' +
        '    max-width: 980px; \n' +
        '    margin: 0 auto; \n' +
        '    padding: 45px; \n' +
        '} \n' +
        '\n' +
        '@media (max-width: 767px) { \n' +
        '.markdown-body { \n' +
        '        padding: 15px; \n' +
        '    } \n' +
        '} \n' +
        '</style>\n' +
        '<div class="markdown-body">\n';

    // create footer
    let outputFooter = '</div>\n';


    let outputContent = outputHeader + outputBody + outputFooter;


    fs.writeFileSync(outputFile, outputContent);
    console.info('Html written to "' + outputFile + "'");
}

