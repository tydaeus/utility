// minifies css, for more optimal prod deployment

module.exports = {
    prod: {
        files: [{
        	expand: true,
      		cwd: '<%= buildDir %>/styles/output',
            src : ['**/*.css'],
            dest : '<%= buildDir %>/styles/output'
        }]
    }
};
