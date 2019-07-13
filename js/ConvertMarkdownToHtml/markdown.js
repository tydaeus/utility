/*
 * Wraps the markdown processing section of the utility.
 */

const Remarkable = require('remarkable');


module.exports = {};

/**
 * Converts an already-read markdown document to html
 * @param doc {string} the markdown document, as a single string
 * @returns {string} doc converted to html
 */
module.exports.convert = function(doc) {
    let converter = new Remarkable();

    return converter.render(doc);
};