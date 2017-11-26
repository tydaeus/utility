'use strict';

// require non-angular library dependencies first
var _ = require('lodash');
// require jquery before angular to use full jquery instead of angular's jqLite
var $ = require('jquery');

// require angular and all angular libraries before requiring/declaring custom angular
var angular = require('angular');

// require modules that will be used by app before declaring app
require('../../modules/test/test.module');

// must declare angular app module before adding/requiring any parts of this module
var demoApp = angular.module('demoApp', ['test']);

demoApp.controller('demoController', function($scope, $interval, tester) {
    $scope.i = 1;

    $interval(function() {
        $scope.i++;
    }, 500);

    tester();
});