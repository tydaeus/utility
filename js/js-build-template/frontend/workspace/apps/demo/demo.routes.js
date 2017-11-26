'use strict';

var angular = require('angular');

angular.module('demo')
.config(function($routeProvider) {
    $routeProvider.when('/', {
        templateUrl: 'home/home.tpl.html',
        controller: 'homeController'
    });
});