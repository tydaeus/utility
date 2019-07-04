/*
 * Encapsulates css processing functionality
 */
const path = require('path');
const fs = require('fs');

module.exports = {};

let defaultStyleSheetCache = null;

const readDefaultStyleSheet = function() {
    if (!defaultStyleSheetCache) {
        defaultStyleSheetCache = fs.readFileSync(path.join(__dirname, 'assets/github-markdown.css'));
    }

    return defaultStyleSheetCache;
};

module.exports.getCssStyleSheetAsEmbeddedTag = function() {
    let css = readDefaultStyleSheet();

    return '<style>\n' +
            css +
           '\n</style>\n';
};