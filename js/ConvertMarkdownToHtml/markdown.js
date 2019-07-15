/*
 * Wraps the markdown processing section of the utility.
 */

const commonmark = require('commonmark');


module.exports = {};

/**
 * Converts an already-read markdown document to html
 * @param doc {string} the markdown document, as a single string
 * @returns {string} doc converted to html
 */
module.exports.convert = function(doc) {
    let reader = new commonmark.Parser();
    let writer = new commonmark.HtmlRenderer();
    let parsed = reader.parse(doc);
    return writer.render(parsed);
};