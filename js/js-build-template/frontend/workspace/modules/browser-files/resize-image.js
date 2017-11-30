'use strict';

var _ = require('underscore');

function resizeImage(image, settings) {

    var _settings = _.extend({}, resizeImage.defaultSettings, settings);
    
    return new Promise(function(resolve, reject) {

        // ensure the base image is ready for use before attempting resize
        if (image.complete) {
            performResize();
        } else {
            image.onload = performResize;
        }

        function performResize() {
            var canvas = document.createElement('canvas');
            var context = canvas.getContext('2d');

            canvas.height = _settings.height;
            canvas.width = _settings.width;
            context.drawImage(image, 0, 0, _settings.width, _settings.height);

            var result = new Image();
            result.src = canvas.toDataURL('image/jpeg');

            result.onload = function() { resolve(result); };
            result.onerror = reject;
        }
    });

}

resizeImage.defaultSettings = {
    proportional : true,
    width: 500,
    height: 500,
    prefer: -1
};


module.exports = resizeImage;