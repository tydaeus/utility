'use strict';

require('angular')
    .module('demo')
    .controller('page2Controller', function($scope, $location) {
        $scope.goto = function goto(path) {
            $location.path(path);
        }
    });