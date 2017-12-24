/*
    Browserify is a tool that converts node-style (CommonJS) modules into
    browser-style code with CommonJS require() specification.

    Browserify looks at package.json for most of its configuration:
        - browser defines module names to associate with js files, and
          overrides browserify's default assumption that all modules will be
          in node_modules

    Browserify-shim is another plugin involved with browserify configuration.
    Shim is also configured through package.json and allows you to wrap a js
    file that is not packaged for CommonJS for use as a module.

    The grunt-browserify plugin makes it easier to use and configure browserify
    as part of the grunt build process.

 */

module.exports = {
	main: {
        // src files are considered as entry points into the application;
        // requirements are resolved starting with these files and resolving
        // each require()'s path
        src: [
            '<%= build %>/apps/main.app.js'
        ],
        dest: '<%= build %>/main.app.js'
	}
};