const commonmark = require('commonmark');
const path = require('path');
const fs = require('fs');

let inputFile, outputFile;
if (process.argv.length > 2) {
     inputFile = process.argv[2];
}

if (process.argv.length > 3) {
    outputFile = process.argv[3];
}

if (!outputFile) {
    outputFile = inputFile + '.html';
    console.info('No outputFilePath specified, defaulting to: ' + outputFile);
}

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
    '</style>\n' +
    '<div class="markdown-body">\n';

// create footer
let outputFooter = '</div>\n';


let outputContent = outputHeader + outputBody + outputFooter;


fs.writeFileSync(outputFile, outputContent);
console.info('Html written to "' + outputFile + "'");