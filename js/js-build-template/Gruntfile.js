'use strict';

const path = require('path');

module.exports = function(grunt) {

    // where to look for dirs containing source
    const sourceRoot = path.join(process.cwd(), 'frontend');
    // where to place dirs containing temporary build files
    const buildRoot = path.join(process.cwd(), 'temp');
    // where to place dirs containing built output files
    const publishRoot = path.join(process.cwd());

    /*
        load-grunt-config sets grunt up to easily pull tasks from multiple
        files.

        Grunt targets are defined in grunt/, with one file for each grunt task,
        named based on the task's name. Task definitions are loaded based on
        loadGruntTasks configuration, or can also be defined within grunt/.

        grunt/aliases holds any composite tasks (aliases)
     */
    require('load-grunt-config')(grunt, {
        // path to task definition files, defaults to "grunt"
        // configPath: path.join(process.cwd(), 'grunt'),

        // automatically do grunt.initConfig
        init: true,

        // data passed into grunt config
        //  - in strings, will replace <%= vname %> with the value of var vname
        data: {
            // source for build
            source: path.join(sourceRoot, 'workspace'),
            // where to put temporary generated files during the build process
            build: path.join(buildRoot, 'build'),
            // where built code ends up
            publish: path.join(publishRoot, 'public')
        },

        // function to use to merge the config files
        // mergeFunction: require('recursive-merge'),

        // configure how to auto-load grunt tasks. Set to false to disable
        // auto-load (manual load only)
        loadGruntTasks: {
            // look for grunt task definitions in package.json's devDependencies list
            scope: 'devDependencies',
            // only use filenames matching this pattern for configuring grunt tasks
            pattern: 'grunt-*',
            // load matching tasks from package.json
            config: require('./package.json')
        }

        // optionally post process config object before it is passed to grunt
        // postProcess: function(config) {},

        // optionally manipulate the config object before it is merged with the data object
        // preMerge: function(config, data) {}


        // use grunt --config-debug [target] to see the config object generated
        // by load-grunt-config
    });

};