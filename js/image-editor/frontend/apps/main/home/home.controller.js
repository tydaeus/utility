'use strict';

const pickFiles = require('../../../modules/browser-files/pick-files');
const readFiles = require('../../../modules/browser-files/read-files');
const resizeImage = require('../../../modules/image-editing/resize-image');
const saveFile = require('../../../modules/browser-files/save-file');
const uriToBuffer = require('../../../modules/node-files/uri-to-buffer');
const _ = require('underscore');
const electron = window.require('electron');
const testMode = electron.remote.getGlobal('testMode');
const fs = window.require('fs');
const path = require('path');

require('angular')
    .module('main')
    .controller('homeController', [
        '$scope',
        function(
            $scope
        ) {

            $scope.imageWidth = 1200;
            $scope.saveName = 'reduced';

            // TODO: remove from testMode (complete)
            if (testMode) {
                $scope.loadFiles = () => {
                    electron.remote.dialog.showOpenDialog({
                        properties: ['openFile', 'multiSelections']}, filePathsArr =>
                    {
                        console.info('filePathsArr', filePathsArr);

                        const files = [];

                        _(filePathsArr).each((filePath) => {
                            let file = {};

                            file.path = filePath;
                            file.name = path.basename(filePath.replace(/\\/g, '/'));
                            file.data = 'file://' + filePath;
                            files.push(file);
                        });

                        console.info('files', files);

                        filesRead(files);
                    });
                };
            } else {
                $scope.loadFiles = function() {
                    pickFiles()
                        .then(function(files) {
                            return readFiles(files, 'dataURL');
                        })
                        .then(filesRead);
                };
            }


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

            // select a direcctory and save all files there
            $scope.saveAllFiles = function () {
                // electron: open a dialog to pick a directory to save to
                electron.remote.dialog.showOpenDialog({
                    properties: ['openDirectory'],
                    multiSelections: false}, dirnameArr =>
                {
                    const dirName = dirnameArr[0];
                    console.info('dirName', dirName);

                    _($scope.files).each((file, i) => {
                        const ext = path.extname(file.path);
                        file.saveName = $scope.saveName + '-' + i;
                        fs.writeFileSync(path.join(dirName, file.saveName + ext), uriToBuffer(file.imageData));
                    });

                });

            };
        }
    ]);



