/*
 * Encapsulates css processing functionality
 */
const path = require('path');
const fs = require('fs');

module.exports = {};

let defaultStyleSheetCache = null;

// read css file
// FUTURE: allow specifying alternative css file
// FUTURE: allow linking css file instead of embedding?
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