module.exports = function(grunt) {

    var path = require('path');

    require('load-grunt-config')(grunt, {
        // path to task definition files, defaults to "grunt"
        // configPath: path.join(process.cwd(), 'grunt'),

        // automatically do grunt.initConfig
        init: true,

        // data passed into grunt config
        //  - in strings, will replace <%= vname %> with the value of var vname
        data: {

        },

        // function to use to merge the config files
        // mergeFunction: require('recursive-merge'),

        // pass options into load-grunt-tasks; set to fals to disable auto loading tasks
        loadGruntTasks: {
            // only use filenames matching this pattern for configuring grunt tasks
            pattern: 'grunt-*',
            // load task configurations from package.json
            config: require('./package.json'),
            // only load config from devDependencies, not from other objects in package.json
            scope: 'devDependencies'
        }

        // optionaly post process config object before it is passed to grunt
        // postProcess: function(config) {},

        // optionally manipulate the config object before it is merged with the data object
        // preMerge: function(config, data) {}

    });

};