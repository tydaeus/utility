'use strict';

const resizeImage = require('../../../modules/image-editing/resize-image');
const saveFile = require('../../../modules/browser-files/save-file');
const uriToBuffer = require('../../../modules/node-files/uri-to-buffer');
const _ = require('underscore');
const electron = window.require('electron');
const testMode = electron.remote.getGlobal('testMode');
const cmdLineParams = electron.remote.getGlobal('cmdLineParams');
const process = electron.remote.getGlobal('process')
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
            $scope.saveExtension = 'reduced';

            if (cmdLineParams.length > 0) {
                console.info('Loading files specified on command-line.');
                filesPicked(cmdLineParams).then(() => {
                    $scope.saveAllFilesSameDir();
                    process.exit();
                });

            }

            $scope.loadFiles = () => {
                electron.remote.dialog.showOpenDialog({
                    properties: ['openFile', 'multiSelections']}, filesPicked);
            };

            function filesPicked(filePathsArr) {
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

                return filesRead(files);
            }

            /**
             * Uses a file's name to generate its post-reduction name by adding '.reduced' before its extension and
             * assuming the file will end up in the same dir as the original. E.g. 'C:/temp/foo.jpg' will be renamed to
             * 'C:/temp/foo.reduced.jpg'.
             * @param rawFileName full path to file including name and extension
             * @returns string generated name for post-reduction file
             */
            function autoRename(rawFileName) {
                let fileName = rawFileName.replace(/\\/g, '/');
                const ext = path.extname(fileName);
                const dirname = path.dirname(fileName);
                const basename = path.basename(fileName, ext);

                return path.join(dirname, basename + '.' + $scope.saveExtension + ext);
            }

            function filesRead(files) {
                const promises = [];

                for (let i = 0; i < files.length; i++) {
                    promises.push(modifyImage(files[i]));
                }
                $scope.files = files;
                console.info(files);
                console.info('promises', promises);

                return Promise.all(promises);
            }

            function modifyImage(file) {
                let image = new Image();
                image.src = file.data;

                return resizeImage(image, { width: $scope.imageWidth }).then(function(resizedImage) {
                    console.info('image resized: ' + file.path);
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

            $scope.saveAllFilesSameDir = function () {
                console.info('Saving all files to their home dirs.');

                _($scope.files).each((file, i) => {
                    let savePath = autoRename(file.path);
                    file.saveName = path.basename(savePath);
                    fs.writeFileSync(savePath, uriToBuffer(file.imageData));
                });
            };

            // select a directory and save all files there
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
                        file.saveName = $scope.saveExtension + '-' + i;
                        fs.writeFileSync(path.join(dirName, file.saveExtension + ext), uriToBuffer(file.imageData));
                    });

                });

            };
        }
    ]);



