'use strict';

require('angular').module('demo')
    .controller('homeController', function($scope, $interval, $location) {

        function updateTime() {
            var time = new Date();
            $scope.time = time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds();
        }

        updateTime();

        $interval(updateTime, 250);
    });