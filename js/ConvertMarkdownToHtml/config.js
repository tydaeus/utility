
const files = [];

const processArgs = function() {

    for (let i = 2; i < process.argv.length; i++) {
        files.push(process.argv[i]);
    }

};

module.exports = {
    files : files,
    processArgs: processArgs
};