// sorts css properties for easier troubleshooting
module.exports = {
    options: {
        config: 'config/.csscomb.json'
    },
    default: {
        expand: true,
        cwd: '<%= buildDir %>/css/',
        // skip already minified css
        src: ['*.css', '!*.min.css'],
        dest: '<%= buildDir %>/css/'
    }
};