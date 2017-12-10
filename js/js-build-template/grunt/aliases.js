var exports = {};

exports.default = [
    'clean',
    'copy:build',
    'build-css',
    'html2js:demo',
    'html2js:main',
    'browserify:demo',
    'browserify:main',
    'copy:publish-js',
    'copy:publish-css',
    'copy:publish-html'
];

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