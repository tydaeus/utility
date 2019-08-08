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

        let contentsList = [tocContent];

        let headingWalker, headingSubNode;

        // FUTURE: scan headings to determine outermost indent level (e.g. if no h1's present in TOC, don't indent h2)

        for (let i = 0; i < headings.length; i++) {

            // only operate on headings - non-headings could mess us up
            if (headings[i].node.type === 'heading' && headings[i].node.level > 0) {
                let headingItem = new commonmark.Node('item');
                headingItem.appendChild(buildLinkFromHeadingObj(headings[i]));

                // indent new insertion by creating sublists based on heading level
                while (contentsList.length < headings[i].node.level) {
                    let sublist = new commonmark.Node('list');
                    sublist.listType = 'bullet';
                    sublist.listStart = null;
                    contentsList[0].appendChild(sublist);
                    contentsList.unshift(sublist);
                }
                // or outdent new insertion by removing sublists until at heading level
                while (contentsList.length > headings[i].node.level) {
                    contentsList.shift();
                }

                contentsList[0].appendChild(headingItem);
            }
            // report malformed doc, but continue
            else {
                console.error('ERR: non-heading or invalid heading node included in heading list', headings[i].node)
            }
        }

        function buildLinkFromHeadingObj(headingObj) {
            headingWalker = headingObj.node.walker();
            let link = new commonmark.Node('link');
            link.destination = '#' + headingObj.id;

            let itemText;
            let prevNode = null;
            while(event = headingWalker.next()) {
                headingSubNode = event.node;

                // TODO: clone all nodes contained within the heading, not just the text.
                //  Can determine child vs. sibling relationships by comparing prevNode with headingSubNode.next
                //  property (?), but need to track traversal in more detail.
                if (event.entering && headingSubNode.type === 'text') {
                    itemText = new commonmark.Node('text');
                    itemText.literal = headingSubNode.literal;

                    link.appendChild(itemText);
                }

                prevNode = headingSubNode;
            }

            return link;
        }

        tocNode.insertAfter(tocContent);
        tocNode.unlink();
    }

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