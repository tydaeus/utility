module.exports = {
    // concat css built from libraries into mrcs-lib.css
    cssLib : {
        files: [
            // concat static library files first
            {
                src: '<%= buildDir %>/assets/styles/css/static-lib/**/*.css',
                dest: '<%= buildDir %>/assets/styles/css/static-lib/static.lib.css'
            },
            // concat customizable library files
            {
                src: [
                    // bootstrap files, core followed by theme
                    '<%= buildDir %>/assets/styles/css/lib/bootstrap.css',
                    '<%= buildDir %>/assets/styles/css/lib/bootstrap-theme.css',

                    // anything else in lib
                    '<%= buildDir %>/assets/styles/css/lib/**/*.css'
                ],
                dest: '<%= buildDir %>/assets/styles/css/lib/cust.lib.css'
            },
            // combine all library files
            {
                src: [
                    '<%= buildDir %>/assets/styles/css/static-lib/static.lib.css',
                    '<%= buildDir %>/assets/styles/css/lib/cust.lib.css'
                ],
                dest: '<%= publishDir %>/assets/css/mrcs.lib.css'
            }
        ]

    },
    // concat custom-built css into mrcs.css
    cssApp : {
    	src: [
    		'<%= buildDir %>/assets/styles/css/**/*.css',
            // anything designated as a lib should get ignored in custom css
    		'!<%= buildDir %>/assets/styles/css/**/*.lib.css',
            '!<%= buildDir %>/assets/styles/css/lib/**'
    	],
      	dest: '<%= publishDir %>/assets/css/mrcs.css'
    }
};
