/*
 * Controls configuration used throughout the app.
 */
module.exports = {};

// files to be converted
module.exports.files = [];

// processes command-line arguments.
// FUTURE: move this somewhere else?
module.exports.processArgs = function() {

    for (let i = 2; i < process.argv.length; i++) {
        module.exports.files.push(process.argv[i]);
    }

};
