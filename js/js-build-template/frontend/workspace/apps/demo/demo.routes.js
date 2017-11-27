'use strict';

var angular = require('angular');

angular.module('demo')
.config(function($routeProvider) {
    $routeProvider
        .when('/', {
            templateUrl: 'home/home.tpl.html',
            controller: 'homeController'
        })
        .when('/page2', {
            templateUrl: 'page2/page2.tpl.html',
            controller: 'page2Controller'
        });
});