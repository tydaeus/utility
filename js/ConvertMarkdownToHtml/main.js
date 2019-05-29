const commonmark = require('commonmark');
const path = require('path');
const fs = require('fs');

let inputFile, outputFile;

for (let i = 2; i < process.argv.length; i++) {
    inputFile = process.argv[i];
    outputFile = inputFile + '.html';
    convertMarkdownFile(inputFile, outputFile);
}

function convertMarkdownFile(inputFile, outputFile) {
    console.info('Reading markdown from "' + inputFile + '"');

    let inputContent = fs.readFileSync(inputFile, {encoding: 'utf8'});

    // convert markdown to html
    let reader = new commonmark.Parser();
    let writer = new commonmark.HtmlRenderer();
    let parsed = reader.parse(inputContent);
    let outputBody = writer.render(parsed);

    // read css file
    // FUTURE: allow specifying alternative css file
    // FUTURE: allow linking css file instead of embedding?
    let css = fs.readFileSync(path.join(__dirname, 'assets/github-markdown.css'));

    // create header
    let outputHeader =
        '<style>\n' +
        css +
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

