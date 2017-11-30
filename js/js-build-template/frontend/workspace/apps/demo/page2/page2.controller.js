'use strict';

var pickFiles = require('../../../modules/browser-files/pick-files');
var readFiles = require('../../../modules/browser-files/read-files');
var resizeImage = require('../../../modules/browser-files/resize-image');

require('angular')
    .module('demo')
    .controller('page2Controller', [
        '$scope',
        function ($scope) {
            $scope.loadFiles = function() {
                pickFiles()
                    .then(function(files) {
                        return readFiles(files, 'dataURL');
                    })
                    .then(filesRead);
            };

            function filesRead(files) {

                for (var i = 0; i < files.length; i++) {
                    modifyImage(files[i]);
                }
                $scope.files = files;
                console.info(files);
            }

            function modifyImage(file) {
                var image = new Image();
                image.src = file.data;

                resizeImage(image, 100, 75).then(function(resizedImage) {
                    file.imageData = resizedImage.src;
                    $scope.$apply();
                });
            }

        }]);