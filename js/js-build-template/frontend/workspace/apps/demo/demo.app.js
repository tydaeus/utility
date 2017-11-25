'use strict';

var angular = require('angular');

console.info('demo.app.js run');

var demoApp = angular.module('demoApp', []);

demoApp.controller('demoController', function($scope, $interval) {
    $scope.i = 1;

    $interval(function() {
        $scope.i++;
    }, 500);
});