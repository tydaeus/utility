var saveLicense = require('uglify-save-license');

module.exports = {
    options: {
        drop_console: true,
        compress: {},
        report: 'min',
        preserveComments: saveLicense
    },
    dist: {
        files: {
            "<%= buildDir %>**/*.app.js": "<%= buildDir %>**/*.app.js"
        }
    }

};