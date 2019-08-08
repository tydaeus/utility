/*
 * Controls configuration used throughout the app.
 */

module.exports = {};

// files to be converted
module.exports.files = [];

options = {
    recurse: false,
    localCss: false,
    testMode: false,
    canonical: false
};
module.exports.options = options;

function processFlag(flag) {
    if (/^--recurse$/i.test(flag)) {
        options.recurse = true;
        console.info('Recursive mode enabled.');
    }
    else if (/^--local-?css$/i.test(flag)) {
        options.localCss = true;
        console.info('Linking css locally.');
    }
    else if (/^--test(-?mode)?$/i.test(flag)) {
        options.testMode = true;
        console.info('Test mode enabled.');
    }
    else if (/^--canonical$/i.test(flag)) {
        options.canonical = true;
        console.info('Canonical mode enabled.');
    }
    // FUTURE: if many other options added, need a more expansive processing pattern and should probably extract
    // elsewhere
    // no other options supported currently
    else {
        console.error('ERR: Unrecognized flag "' + flag + '"');
        process.exit(1);
    }

}

// processes command-line arguments.
// FUTURE: move this somewhere else?
module.exports.processArgs = function() {

    for (let i = 2; i < process.argv.length; i++) {
        if (/^-/.test(process.argv[i])) {
            processFlag(process.argv[i]);
        } else {
            module.exports.files.push(process.argv[i]);
        }
    }

};
