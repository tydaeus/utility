'use strict';

function resizeImage(image, width, height) {
    var clone = new Image();
    clone.src = image.src;

    return new Promise(function(resolve, reject) {
        var canvas = document.createElement('canvas');
        var context = canvas.getContext('2d');

        canvas.height = height;
        canvas.width = width;
        context.drawImage(clone, 0, 0, width, height);

        var result = new Image();
        result.src = canvas.toDataURL('image/jpeg');

        clone.onload = function() { resolve(result); };
        clone.onerror = reject;
    });
}

module.exports = resizeImage;