/*
 * Wraps the markdown processing section of the utility.
 */

const commonmark = require('commonmark');
const config = require('./config');


module.exports = {};

function highlightCode(parsed) {
    let highlight = require('highlight.js');
    let walker = parsed.walker();
    let event, node, highlightOutput, codeNode;

    while ((event = walker.next())) {
        node = event.node;

        if (node.type === 'code_block') {
            // code blocks cannot contain sub-blocks and contain their own literal text
            if (event.entering) {
                console.info('entering code_block, before:');
                console.info(node.literal);

                if (node.info) {
                    highlightOutput = highlight.highlight(node.info, node.literal, true);
                } else {
                    highlightOutput = highlight.highlightAuto(node.literal);
                }
                // TODO: replace highlightjs css classes with github markdown css classes

                console.info('after:');
                console.info(highlightOutput.value);
            }

            codeNode = new commonmark.Node('html_block');
            codeNode.literal = '<pre>\n' + highlightOutput.value + '\n</pre>';
            node.insertAfter(codeNode);
            node.unlink();
        }

    }
}

// adds id links to headings
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

    while ((event = walker.next())) {
        node = event.node;
        if (node.type === 'heading') {
            if (event.entering) {
                inHeading = true;
                headingText = '';
                headingLevel = node.level;
            } else {
                inHeading = false;

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
            headingText += node.literal;
        }
        // inspect html_blocks for directives (currently TOC is only supported directive)
        else if (node.type === 'html_block') {
            if (event.entering) {
                inHtmlBlock = true;

                // capture this node if it's the TOC directive
                if (/<!--\s*TOC\s*-->/.test(node.literal)) {
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
            while(event = headingWalker.next()) {
                headingSubNode = event.node;

                // FUTURE: clone all nodes contained within the heading, not just the text.
                //  Can determine child vs. sibling relationships by comparing prevNode with headingSubNode.next
                //  property (?), but need to track traversal in more detail.
                if (event.entering && headingSubNode.type === 'text') {
                    itemText = new commonmark.Node('text');
                    itemText.literal = headingSubNode.literal;

                    link.appendChild(itemText);
                }

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

    if (!config.options.canonical) {
        buildToc(parsed);
    }

    if (config.options.testMode && !config.options.canonical) {
        highlightCode(parsed);
    }

    return writer.render(parsed);
};