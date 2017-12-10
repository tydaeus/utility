module.exports = {

    // provide reasonable default options
    // target-specific options will override
    options: {
        // portion of path to get stripped when determining template url
        base: '<%= build %>/apps',
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

    demo: {
        options: {
            base: '<%= build %>/apps/demo/',
            module: 'demo.templates'
        },
        src: ['<%= build %>/apps/demo/**/*.tpl.html'],
        dest: '<%= build %>/apps/demo/demo.templates.js'
    },

    main: {
        options: {
            base: '<%= build %>/apps/main/',
            module: 'main.templates'
        },
        src: ['<%= build %>/apps/main/**/*.tpl.html'],
        dest: '<%= build %>/apps/main/main.templates.js'
    }
};
