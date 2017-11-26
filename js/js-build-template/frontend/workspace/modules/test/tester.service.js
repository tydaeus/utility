'use strict';

var angular = require('angular');

angular.module('test')
    .factory('tester', function() {
        console.info('tester service constructed');

        return function() {
            console.info('tester service invoked');
        };
    });