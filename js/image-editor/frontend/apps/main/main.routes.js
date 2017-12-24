'use strict';

const angular = require('angular');

angular.module('main')
    .config([
        '$routeProvider',
        function ($routeProvider) {
            $routeProvider
                .when('/', {
                    templateUrl: 'home/home.tpl.html',
                    controller: 'homeController'
                });
        }]);