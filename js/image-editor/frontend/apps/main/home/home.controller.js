'use strict';

const pickFiles = require('../../../modules/browser-files/pick-files');
const readFiles = require('../../../modules/browser-files/read-files');
const resizeImage = require('../../../modules/image-editing/resize-image');
const saveFile = require('../../../modules/browser-files/save-file');
const _ = require('underscore');

require('angular')
    .module('main')
    .controller('homeController', [
        '$scope',
        function(
            $scope
        ) {
            $scope.imageWidth = 1200;
            $scope.saveName = 'reduced';

            $scope.loadFiles = function() {
                pickFiles()
                    .then(function(files) {
                        return readFiles(files, 'dataURL');
                    })
                    .then(filesRead);
            };

            function filesRead(files) {

                for (let i = 0; i < files.length; i++) {
                    modifyImage(files[i]);
                }
                $scope.files = files;
                console.info(files);
            }

            function modifyImage(file) {
                let image = new Image();
                image.src = file.data;

                resizeImage(image, { width: $scope.imageWidth }).then(function(resizedImage) {
                    file.imageData = resizedImage.src;
                    $scope.$apply();
                });
            }

            $scope.saveFile = function(file) {
                new Promise(function(resolve, reject) {
                    if (!file.saveName) {
                        file.saveName = $scope.saveName
                    }

                    saveFile({
                        data: file.imageData,
                        name: file.saveName
                    });
                    resolve();
                });
            };

            // note that this has the unfortunate side effect of opening multiple save dialogs at once if user's
            // settings specify to ask where to save each file
            $scope.saveAllFiles = function () {
                electron.remote.dialog.showOpenDialog({properties: ['openDirectory']}, filename => {
                    console.info('filename', filename);
                });
                return;

                _($scope.files).each(function(file, i) {
                    file.saveName = $scope.saveName + '-' + i;
                    $scope.saveFile(file);
                });
            };
        }
    ]);



