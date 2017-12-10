'use strict';

var angular = require('angular');

angular.module('main')
    .config([
        '$routeProvider',
        function ($routeProvider) {
            $routeProvider
                .when('/', {
                    templateUrl: 'home/home.tpl.html'
                })
                .when('/linking', {
                    templateUrl: 'linking/linking.tpl.html'
                })
        }]);