module.exports = {
    options: {
        browsers: [
            "Android 2.3",
            "Android >= 4",
            "Chrome >= 20",
            "Firefox >= 24",
            "Explorer >= 11",
            "iOS >= 6",
            "Opera >= 12",
            "Safari >= 6"
        ]
    },
    default: {
        options: {
            map: true
        },
        src: '<%= buildDir %>/**/*.css'
    }
};