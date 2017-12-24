// minifies css, for more optimal prod deployment

module.exports = {
    prod: {
        files: [{
        	expand: true,
      		cwd: '<%= build %>/styles/output',
            src : ['**/*.css'],
            dest : '<%= build %>/styles/output'
        }]
    }
};
