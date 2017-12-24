'use strict';

// require non-angular library dependencies first
// require jquery before angular to use full jquery instead of angular's jqLite
const $ = require('jquery');

// require angular and all angular libraries before requiring/declaring custom angular
//      NOTE: angular dependencies are registered with the angular object, so further var assignments are unnecessary
const angular = require('angular');
require('angular-route');
require('angular-ui-bootstrap');

// require angular modules that will be used by app before declaring app
require('../modules/test/test.module');
require('./main/main.templates'); // created as part of build


// must declare angular app module before declaring/requiring any parts of this app
var main = angular.module('main', ['ngRoute', 'test', 'main.templates']);

// require app-specific angular service, directive, and controller declarations

// perform angular config
require('./main/main.routes');

main.run([
    '$rootScope',
    '$location',
    function ($rootScope, $location) {

        $rootScope.goto = function goto(path) {
            $location.path(path);
        }
    }]);