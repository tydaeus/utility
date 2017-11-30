'use strict';

function resizeImage(image, width, height) {

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

            canvas.height = height;
            canvas.width = width;
            context.drawImage(image, 0, 0, width, height);

            var result = new Image();
            result.src = canvas.toDataURL('image/jpeg');

            result.onload = function() { resolve(result); };
            result.onerror = reject;
        }
    });

}


module.exports = resizeImage;