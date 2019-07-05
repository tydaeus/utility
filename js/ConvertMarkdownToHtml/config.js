/*
 * Controls configuration used throughout the app.
 */

module.exports = {};

// files to be converted
module.exports.files = [];

options = {
    recurse: false
};
module.exports.options = options;

function processFlag(flag) {
    if (/^--recurse$/i.test(flag)) {
        options.recurse = true;
        console.info('Recursive mode enabled.');
    }
    // no other options supported currently
    // FUTURE: if other options added, need a more expansive processing pattern and should probably extract elsewhere
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
