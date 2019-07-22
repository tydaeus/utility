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
    let event, node, headingLevel, newNode, id;
    let headingText = '';
    let inHeading = false;

    let writer = new commonmark.HtmlRenderer();

    let generatingToc = false;
    let tocNode = null;
    let inHtmlBlock = false;

    // track generated TOC ids to prevent duplication
    const idMap = {};
    const headings = [];

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

                // insert linking symbol before heading if table of contents has been requested
                if (generatingToc) {
                    newNode = new commonmark.Node('html_inline');
                    id = textToId(headingText);
                    newNode.literal = '<a id="' + id +'" href="#' + id  + '" class="anchor">&sect;</a>';

                    node.firstChild.insertBefore(newNode, null);

                    headings.push({ node: node, id: id });
                }


            }
        }
        // strip text content of heading for purposes of id generation
        else if (inHeading && node.type === 'text' && generatingToc) {
            console.info('in heading text: ' + node.literal);
            headingText += node.literal;
        }
        // inspect html_blocks for directives (currently TOC is only supported directive)
        else if (node.type === 'html_block') {
            if (event.entering) {
                inHtmlBlock = true;
                console.info('entering html_block: ' + node.literal);

                // capture this node if it's the TOC directive
                if (/<!--\s*TOC\s*-->/.test(node.literal)) {
                    console.info('TOC directive detected.');
                    generatingToc = true;

                    if (tocNode) {
                        console.error('ERR: multiple TOC directives detected');
                    } else {
                        tocNode = node;
                    }
                }

            }
        }

    }

    // generate and insert the table of contents if applicable
    if (generatingToc && tocNode) {
        console.info("generating TOC")
        let tocContent = new commonmark.Node('list');
        tocContent.listType = 'bullet';
        tocContent.listStart = null;

        let headingWalker, headingSubNode;

        for (let i = 0; i < headings.length; i++) {
            headingWalker = headings[i].node.walker();

            let headingItem = new commonmark.Node('item');
            let itemText;
            while(event = headingWalker.next()) {
                headingSubNode = event.node
                // TODO: clone all nodes contained within the heading, not just the text. How to determine child vs. sibling relationships?
                if (event.entering && headingSubNode.type === 'text') {
                    itemText = new commonmark.Node('text');
                    itemText.literal = headingSubNode.literal;
                    headingItem.appendChild(itemText);
                }
            }

            tocContent.appendChild(headingItem);
        }

        // let textChild = new commonmark.Node('text');
        // textChild.literal = 'Table of Contents';
        // tocContent.appendChild(textChild);

        tocNode.insertAfter(tocContent);
        tocNode.unlink();
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