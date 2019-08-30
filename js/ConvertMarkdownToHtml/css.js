/*
 * Encapsulates css processing functionality
 */
const path = require('path');
const fs = require('fs');
const config = require('./config.js');

module.exports = {};

const DEFAULT_STYLESHEET_NAME = 'github-markdown.css';
const HIGHLIGHT_STYLESHEET_NAME = 'github-highlight.css';

let defaultStyleSheetCache = null;

// FUTURE: allow configuring alternative css file(s)
// FUTURE: allow configuring other linking options

const stylesheetCache = {};

const readStyleSheet = function(stylesheetName) {
    if (!stylesheetCache[stylesheetName]) {
        stylesheetCache[stylesheetName] = fs.readFileSync(path.join(__dirname, 'assets/' + stylesheetName));
    }

    return stylesheetCache[stylesheetName];
};

// future: embed only needed css?
module.exports.getCssStyleSheetAsEmbeddedTag = function() {
    let stylesheet = readStyleSheet(DEFAULT_STYLESHEET_NAME);
    stylesheet += readStyleSheet(HIGHLIGHT_STYLESHEET_NAME);

    return '<style>\n' +
            stylesheet +
           '\n</style>\n';
};

module.exports.getLinkLocalCssTag = function() {
    let linkTags = '<link rel="stylesheet" type="text/css" href="./' + DEFAULT_STYLESHEET_NAME + '">\n';
    linkTags += '<link rel="stylesheet" type="text/css" href="./' + HIGHLIGHT_STYLESHEET_NAME + '">\n';

    return linkTags;
};

module.exports.createLocalCssIfNeeded = function(dir) {
    ensureLocalCssIsCreated(dir, DEFAULT_STYLESHEET_NAME);
    ensureLocalCssIsCreated(dir, HIGHLIGHT_STYLESHEET_NAME);
};

function ensureLocalCssIsCreated(dir, styleSheetName) {
    const stylesheetPath = path.resolve(dir, styleSheetName);

    if (fs.existsSync(stylesheetPath)) {
        return;
    }

    const stylesheetContent = readStyleSheet(styleSheetName);
    fs.writeFileSync(stylesheetPath, stylesheetContent);
    console.info(styleSheetName + ' written to "' + dir + '"');
}

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