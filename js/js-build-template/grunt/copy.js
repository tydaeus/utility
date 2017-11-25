'use strict';

module.exports = {};

module.exports.build = {
    files: [
        {
            expand: true,
            cwd: '<%= source %>',
            src: ['./**'],
            dest: '<%= buildDir %>'
        },
        // copy over pre-build bootstrap less files
        {
            expand: true,
            src: ['node_modules/bootstrap/less/*'],
            dest: '<%= buildDir %>/styles/less/bootstrap',
            flatten: true
        }
    ]
};

// copy post-build files into <%= publishDir %>
module.exports.publish = {
    files: [
        {
            expand: true,
            cwd: '<%= buildDir %>',
            src: ['./**'],
            dest: '<%= publishDir %>/'
        }
    ]
};