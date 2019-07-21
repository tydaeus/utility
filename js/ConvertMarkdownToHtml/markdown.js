/*
 * Wraps the markdown processing section of the utility.
 */

const commonmark = require('commonmark');
const config = require('./config');


module.exports = {};

// in-progress
// adds id links to headings
// TODO: build Table of Contents
function buildToc(parsed) {
    let walker = parsed.walker();
    let event, node, headingText, headingLevel, newNode, id;
    let inHeading = false;

    let inHtmlBlock = false;

    // track generated TOC ids to prevent duplication
    const idMap = {};

    // generate a unique id based on text content
    function textToId(text) {
        // ensure we have text
        let workingText = text || '_';

        const maxTextLength = 30;

        // crop excessive text
        if (workingText.length > maxTextLength) {
            workingText = workingText.substr(0, maxTextLength - 3) + '...';
        }

        // remove consecutive spaces
        workingText = workingText.replace(/\s+/g, '-');

        if (idMap[workingText]) {
            idMap[workingText]++;
            workingText += idMap[workingText];
        } else {
            idMap[workingText] = 1;
        }

        return workingText;
    }

    // TODO: remove debug messages
    // TODO: check for TOC directive before adding heading anchors
    // TODO: generate TOC
    // TODO: allow configuration
    while ((event = walker.next())) {
        node = event.node;
        if (node.type === 'heading') {
            if (event.entering) {
                inHeading = true;
                headingText = '';
                headingLevel = node.level;
                console.info('entering heading L' + node.level);
            } else {
                inHeading = false;
                console.info('leaving heading L' + node.level);

                console.info('rendered heading: ' + writer.render(node));
                console.info('heading text: ' + headingText);

                newNode = new commonmark.Node('html_inline');

                id = textToId(headingText);
                newNode.literal = '<a id="' + id +'" href="#' + id  + '" class="anchor">&sect;</a>';

                node.firstChild.insertBefore(newNode);

            }
        } else if (inHeading && node.type === 'text') {
            console.info('in heading text: ' + node.literal);
            headingText += node.literal;
        } else if (node.type === 'html_block') {
            if (event.entering) {
                inHtmlBlock = true;
                console.info('entering html_block: ' + node.literal);
            } else {
                inHtmlBlock = false;
                console.info('leaving html_block');
            }
        }

    }

    // process.exit(0);
}


/**
 * Converts an already-read markdown document to html
 * @param doc {string} the markdown document, as a single string
 * @returns {string} doc converted to html
 */
module.exports.convert = function(doc) {
    let reader = new commonmark.Parser();
    let writer = new commonmark.HtmlRenderer();
    let parsed = reader.parse(doc);

    if (config.options.testMode) {
        buildToc(parsed);
    }

    return writer.render(parsed);
};