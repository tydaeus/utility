/*
 * Encapsulates css processing functionality
 */
const path = require('path');
const fs = require('fs');

module.exports = {};

const DEFAULT_STYLESHEET_NAME = 'github-markdown.css';

let defaultStyleSheetCache = null;

// read css file
// FUTURE: allow specifying alternative css file
// FUTURE: allow linking css file instead of embedding?
const readDefaultStyleSheet = function() {
    if (!defaultStyleSheetCache) {
        defaultStyleSheetCache = fs.readFileSync(path.join(__dirname, 'assets/' + DEFAULT_STYLESHEET_NAME));
    }

    return defaultStyleSheetCache;
};

module.exports.getCssStyleSheetAsEmbeddedTag = function() {
    const stylesheet = readDefaultStyleSheet();

    return '<style>\n' +
            stylesheet +
           '\n</style>\n';
};

module.exports.getLinkLocalCssTag = function() {
    return '<link rel="stylesheet" type="text/css" href="./' + DEFAULT_STYLESHEET_NAME + '">\n';
};

module.exports.createLocalCssIfNeeded = function(dir) {
    const stylesheetPath = path.resolve(dir, DEFAULT_STYLESHEET_NAME);

    if (fs.existsSync(stylesheetPath)) {
        return;
    }

    const stylesheetContent = readDefaultStyleSheet();
    fs.writeFileSync(stylesheetPath, stylesheetContent);
    console.info(DEFAULT_STYLESHEET_NAME + ' written to "' + dir + '"');
};

/**
 * @returns {string} style tag for this util's standard customization of the default style
 */
module.exports.getCssCustomizationTag = function() {
    return '<style>\n' +
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
        '</style>\n'
};