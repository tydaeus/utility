module.exports = function(grunt) {

    var path = require('path');

    // folder to start as base of the build (anything outside this won't get built)
    var buildRoot = path.join(process.cwd(), 'frontend');

    require('load-grunt-config')(grunt, {
        // path to task definition files, defaults to "grunt"
        // configPath: path.join(process.cwd(), 'grunt'),

        // automatically do grunt.initConfig
        init: true,

        // data passed into grunt config
        //  - in strings, will replace <%= vname %> with the value of var vname
        data: {
            // source for build
            source: path.join(buildRoot, 'workspace'),
            // where to put temporary generated files during the build process
            buildDir: path.join(buildRoot, 'build'),
            // where built code ends up
            publishDir: path.join(buildRoot, 'public')
        },

        // function to use to merge the config files
        // mergeFunction: require('recursive-merge'),

        // pass options into load-grunt-tasks; set to false to disable auto loading tasks
        loadGruntTasks: {
            // only use filenames matching this pattern for configuring grunt tasks
            pattern: 'grunt-*',
            // load matching tasks from package.json
            config: require('./package.json'),
            // only load config from devDependencies, not from other objects in package.json
            scope: 'devDependencies'
        }

        // optionally post process config object before it is passed to grunt
        // postProcess: function(config) {},

        // optionally manipulate the config object before it is merged with the data object
        // preMerge: function(config, data) {}


        // use grunt --config-debug [target] to see the config object generated
        // by load-grunt-config
    });

};