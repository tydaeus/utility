module.exports = {
    options: {
        // portion of path to get stripped when determining template url
        base: '<%= buildDir %>/app/',
        // angular module to contain the generated templates
        module: 'templates',
        // create a single wrapping module with run block, instead of a module per template
        singleModule: true,
        // add "use strict" directive at the top of generated modules
        useStrict: true,
        // place at top of file
        fileHeaderString: "var angular=require('angular');",
        // instructions for how to minify the html
        htmlmin: {
            collapseBooleanAttributes: true,
            collapseWhitespace: true,
            removeComments: true,
            removeEmptyAttributes: true,
            // deliverable css sometimes requires redundant attributes to be set explicitly
            removeRedundantAttributes: false
        },
        // allow in conjunction with a watch task
        watch: true
    },
    // future: consider splitting application such that shared modules are in one location and app-specific
    // modules contained in their own folder
    general: {

        src: ['<%= buildDir %>/app/**/*.tpl.html'],
        dest: '<%= buildDir %>/app/modules/templates/templates.js'
    }
};
