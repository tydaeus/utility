var exports = {};

exports.demo = [
    'clean',
    'copy:build',
    'build-css',
    'html2js:demo',
    'browserify:demo',
    'copy:publish-js',
    'copy:publish-css',
    'copy:publish-html'
];

exports.default = exports.demo;

exports['compile-bootstrap'] = [
    'copy:bootstrap-lib',
    'copy:bootstrap-custom',
    'less:compile-bootstrap-core',
    'less:compile-bootstrap-theme'
];

exports['build-css'] = [
    'compile-bootstrap',
    'autoprefixer',
    'csscomb'
];

module.exports = exports;