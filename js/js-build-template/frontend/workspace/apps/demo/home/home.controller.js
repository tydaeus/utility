'use strict';

var angular = require('angular');

angular.module('demo')
    .controller('homeController', function($scope, $interval) {

        function updateTime() {
            var time = new Date();
            $scope.time = time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds();
        }

        updateTime();

        $interval(updateTime, 250);
    });