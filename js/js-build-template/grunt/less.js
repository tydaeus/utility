/*
    these are the tasks used to build bootstrap's css in bootstrap's gruntfile; need to migrate into project
grunt.registerTask('less-compile', ['less:compileCore', 'less:compileTheme']);
grunt.registerTask('dist-css', ['less-compile', 'autoprefixer:core', 'autoprefixer:theme', 'csscomb:dist',
    'cssmin:minifyCore', 'cssmin:minifyTheme']);
 */


module.exports = {
    // don't change core unless you need to change core bootstrap functionality
    "compile-bootstrap-core": {
        options: {
            strictMath: true,
            sourceMap: true,
            outputSourceFiles: true,
            sourceMapURL: 'bootstrap.css.map',
            sourceMapFilename: '<%= buildDir %>/assets/styles/css/lib/bootstrap.css.map'
        },
        src: '<%= buildDir %>/assets/styles/less/lib/bootstrap/missingmail-bootstrap.less',
        dest: '<%= buildDir %>/assets/styles/css/lib/bootstrap.css'
    },
    // customizations are achieved by modifying bootstrap-theme and/or its dependencies
    "compile-bootstrap-theme": {
        options: {
            strictMath: true,
            sourceMap: true,
            outputSourceFiles: true,
            sourceMapURL: 'bootstrap-theme.css.map',
            sourceMapFilename: '<%= buildDir %>/assets/styles/css/lib/bootstrap-theme.css.map'
        },
        src: '<%= buildDir %>/assets/styles/less/lib/bootstrap/missingmail-theme.less',
        dest: '<%= buildDir %>/assets/styles/css/lib/bootstrap-theme.css'
    }
};