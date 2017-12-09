'use strict';

module.exports = {};

module.exports.build = {
    files: [
        {
            expand: true,
            cwd: '<%= source %>',
            src: ['**/*.js', '**/*.html'],
            dest: '<%= build %>'
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
            dest: '<%= build %>/styles/less/bootstrap'
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
            dest: '<%= build %>/styles/less/bootstrap'
        }
    ]
};

// copy built js files into <%= publish %>
module.exports['publish-js'] = {
    files: [
        {
            expand: true,
            cwd: '<%= build %>',
            src: '*.app.js',
            dest: '<%= publish %>/',
            flatten: true
        }
    ]
};

// copy built html files into <%= publish %>
module.exports['publish-html'] = {
    files: [
        {
            expand: true,
            cwd: '<%= build %>',
            src: '**/*.index.html',
            dest: '<%= publish %>/',
            flatten: true
        }
    ]
};

// copy built css files into <%= publish %>
module.exports['publish-css'] = {
    files: [
        {
            expand: true,
            cwd: '<%= build %>',
            src: ['styles/css/*.css'],
            dest: '<%= publish %>/',
            flatten: true
        }
    ]
};