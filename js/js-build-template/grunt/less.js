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
            sourceMapFilename: '<%= buildDir %>/styles/css/bootstrap.css.map'
        },
        src: '<%= buildDir %>/styles/less/bootstrap/bootstrap.less',
        dest: '<%= buildDir %>/styles/css/bootstrap.css'
    },
    // customizations are achieved by modifying bootstrap-theme and/or its dependencies
    "compile-bootstrap-theme": {
        options: {
            strictMath: true,
            sourceMap: true,
            outputSourceFiles: true,
            sourceMapURL: 'bootstrap-theme.css.map',
            sourceMapFilename: '<%= buildDir %>/styles/css/lib/bootstrap-theme.css.map'
        },
        src: '<%= buildDir %>/styles/less/bootstrap/theme.less',
        dest: '<%= buildDir %>/styles/css/bootstrap-theme.css'
    }
};