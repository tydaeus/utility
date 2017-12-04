'use strict';

module.exports = {};

module.exports.build = {
    files: [
        {
            expand: true,
            cwd: '<%= source %>',
            src: ['./**'],
            dest: '<%= buildDir %>'
        }
    ]
};

// copy over pre-build bootstrap less files
module.exports['bootstrap-lib'] = {
    files: [
        {
            expand: true,
            cwd: 'node_modules/bootstrap/less/',
            src: ['**/*'],
            dest: '<%= buildDir %>/styles/less/bootstrap'
        }
    ]
};

// copy post-build files into <%= publishDir %>
module.exports.publish = {
    files: [
        {
            expand: true,
            cwd: '<%= buildDir %>',
            src: ['./**/*.app.js', './**/*.index.html'],
            dest: '<%= publishDir %>/'
        }
    ]
};