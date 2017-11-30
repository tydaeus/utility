'use strict';

var _ = require('underscore');

var defaultSettings = {
    proportional : true,
    prefer: -1
};

function resizeImage(image, settings) {

    var settings = _.extend({}, defaultSettings, settings);
    console.info('settings', settings);

    return new Promise(function(resolve, reject) {

        // ensure the base image is ready for use before attempting resize
        if (image.complete) {
            performResize();
        } else {
            image.onload = performResize;
        }

        function performResize() {
            // calculate proper size if proportionality desired
            // TODO: reject if sizing data not valid
            if (settings.proportional) {
                var ratio = image.width / image.height;

                // for now, favor preserving target width over preserving target height
                if (settings.width) {
                    settings.height = Math.floor(settings.width / ratio);
                } else {
                    settings.width = Math.floor(settings.height * ratio);
                }
            }

            var canvas = document.createElement('canvas');
            var context = canvas.getContext('2d');

            canvas.height = settings.height;
            canvas.width = settings.width;
            context.drawImage(image, 0, 0, settings.width, settings.height);

            var result = new Image();
            result.src = canvas.toDataURL('image/jpeg');

            result.onload = function() { resolve(result); };
            result.onerror = reject;
        }
    });

}

module.exports = resizeImage;