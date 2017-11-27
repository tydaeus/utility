var exports = {};

exports.demo = ['clean', 'copy:build', 'html2js:demo', 'copy:publish', 'browserify:demo'];
exports.default = exports.demo;

module.exports = exports;