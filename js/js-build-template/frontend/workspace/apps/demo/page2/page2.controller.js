'use strict';

var pickFiles = require('../../../modules/browser-files/pick-files');

require('angular')
    .module('demo')
    .controller('page2Controller', [
        '$scope',
        function ($scope) {
            $scope.loadFiles = function() {
                pickFiles().then(filesSelected);
            };

            function filesSelected(files) {
                console.info(files);
            }

            // todo: read uploaded files
            function readFile(file) {
                var fileReader = new FileReader();
                fileReader.onloadend = function(e) {
                    deferred.resolve(e.target.result);
                };

                if (!method || method === "arrayBuffer") {
                    fileReader.readAsArrayBuffer(file);
                } else if (method === "text") {
                    fileReader.readAsText(file);
                } else if (method === "dataURL") {
                    fileReader.readAsDataURL(file);
                }
            }
        }]);