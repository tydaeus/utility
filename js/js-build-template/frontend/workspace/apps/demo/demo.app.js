'use strict';

// require non-angular library dependencies first
var _ = require('lodash');
// require jquery before angular to use full jquery instead of angular's jqLite
var $ = require('jquery');

// require angular and all angular libraries before requiring/declaring custom angular
//      NOTE: angular dependencies decorate the angular object, so further requires are unnecessary
var angular = require('angular');
require('angular-route');
require('angular-ui-bootstrap');

// require modules that will be used by app before declaring app
require('../../modules/test/test.module');
require('./demo.templates.js'); // created as part of build


// must declare angular app module before declaring/requiring any parts of this app
var demo = angular.module('demo', ['ngRoute', 'test', 'demo.templates']);

// require app-specific angular service, directive, and controller declarations
require('./home/home.controller');
require('./page2/page2.controller');

// perform angular config
require('./demo.routes');

demo.run([
    '$rootScope',
    '$location',
    function ($rootScope, $location) {
        $rootScope.goto = function goto(path) {
            $location.path(path);
        }
    }]);