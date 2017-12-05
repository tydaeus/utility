'use strict';

module.exports = {};

module.exports.build = {
    files: [
        {
            expand: true,
            cwd: '<%= source %>',
            src: ['**/*.js', '**/*.html'],
            dest: '<%= buildDir %>'
        }
    ]
};

// copy pre-build bootstrap less source files from node_modules
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

// copy customized bootstrap less source files from workspace
module.exports['bootstrap-custom'] = {
    files: [
        {
            expand: true,
            cwd: '<%= source %>/styles/less/bootstrap',
            src: ['**/*'],
            dest: '<%= buildDir %>/styles/less/bootstrap'
        }
    ]
};

// copy built js files into <%= publishDir %>
module.exports['publish-js'] = {
    files: [
        {
            expand: true,
            cwd: '<%= buildDir %>',
            src: '*.app.js',
            dest: '<%= publishDir %>/',
            flatten: true
        }
    ]
};

// copy built html files into <%= publishDir %>
module.exports['publish-html'] = {
    files: [
        {
            expand: true,
            cwd: '<%= buildDir %>',
            src: '**/*.index.html',
            dest: '<%= publishDir %>/',
            flatten: true
        }
    ]
};

// copy built css files into <%= publishDir %>
module.exports['publish-css'] = {
    files: [
        {
            expand: true,
            cwd: '<%= buildDir %>',
            src: ['styles/css/*.css'],
            dest: '<%= publishDir %>/',
            flatten: true
        }
    ]
};