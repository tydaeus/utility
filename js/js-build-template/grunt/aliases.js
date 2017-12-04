var exports = {};

exports.demo = ['clean', 'copy:build', 'html2js:demo', 'copy:publish', 'browserify:demo'];
exports.default = exports.demo;

exports['compile-bootstrap'] = ['copy:bootstrap-lib', 'less:compile-bootstrap-core', 'less:compile-bootstrap-theme'];

module.exports = exports;