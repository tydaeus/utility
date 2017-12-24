/*
 * Removes unused css from build
 */

module.exports = {
	dist: {
        options: {
            // css selectors to preserve, even if they are unused?
            ignore: [
                '.fade',
                '.collapse',
                '.collapsing',
                '.btn-block',
                '.text-strong',
                /(#|\.)navbar(\-[a-zA-Z]+)?/,
                /(#|\.)dropdown(\-[a-zA-Z]+)?/,
                /(#|\.)glyphicon(\-[a-zA-Z]+)?/,
                /(#|\.)(open)/
            ],
            // undocumented option -- which stylesheets to reduce?
            stylesheets: [
                'assets/css/bootstrap.min.css'
            ]
        },
        files: {
            // where to put the resulting css
            '<%= build %>/assets/css/bootstrap.min.css':
            // list all files that use css (e.g. all html files) so uncss can
            // determine what css code is and isn't used.
            [
                '<%= build %>/index.html',
                '<%= build %>/app/**/*.tpl.html'
            ]
        }
  }
};
