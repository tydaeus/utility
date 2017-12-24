module.exports = {
    // concat css built from libraries into mrcs-lib.css
    cssLib : {
        files: [
            // concat static library files first
            {
                src: '<%= build %>/assets/styles/css/static-lib/**/*.css',
                dest: '<%= build %>/assets/styles/css/static-lib/static.lib.css'
            },
            // concat customizable library files
            {
                src: [
                    // bootstrap files, core followed by theme
                    '<%= build %>/assets/styles/css/lib/bootstrap.css',
                    '<%= build %>/assets/styles/css/lib/bootstrap-theme.css',

                    // anything else in lib
                    '<%= build %>/assets/styles/css/lib/**/*.css'
                ],
                dest: '<%= build %>/assets/styles/css/lib/cust.lib.css'
            },
            // combine all library files
            {
                src: [
                    '<%= build %>/assets/styles/css/static-lib/static.lib.css',
                    '<%= build %>/assets/styles/css/lib/cust.lib.css'
                ],
                dest: '<%= publish %>/assets/css/mrcs.lib.css'
            }
        ]

    },
    // concat custom-built css into mrcs.css
    cssApp : {
    	src: [
    		'<%= build %>/assets/styles/css/**/*.css',
            // anything designated as a lib should get ignored in custom css
    		'!<%= build %>/assets/styles/css/**/*.lib.css',
            '!<%= build %>/assets/styles/css/lib/**'
    	],
      	dest: '<%= publish %>/assets/css/mrcs.css'
    }
};
