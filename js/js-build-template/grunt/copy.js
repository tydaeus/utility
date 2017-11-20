'use strict';

var _ = require('lodash');

module.exports = {};

// list each app's name here TODO get this list from Gruntfile
var apps = ['demo'];

// copy core files for each app
_.each(apps, function(app) {
    module.exports[app] = {
        // each app's index file(s)
        files: [
            {
                expand: true,
                src: ['<%= source %>/apps/' + app + '/*.index.html'],
                dest: '<%= buildDir %>/apps/' + app,
                flatten: true
            }
        ]
    };
});

module.exports.less = {
    files: [
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
        // TODO generate description for each app
        {
            expand: true,
            src: ['<%= buildDir %>/**'],
            dest: '<%= publishDir %>/',
            flatten: true
        }
    ]
};