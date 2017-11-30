'use strict';

var pickFiles = require('../../../modules/browser-files/pick-files');
var readFiles = require('../../../modules/browser-files/read-files');

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
                $scope.files = files;
                $scope.$apply();
                console.info(files);
            }

        }]);