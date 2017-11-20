module.exports = {
    less: {
        files: [
            {
                expand: true,
                src: ['node_modules/bootstrap/less/*'],
                dest: '<%= buildDir %>/styles/less/bootstrap',
                flatten: true
            }
        ]
    }
};