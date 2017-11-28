'use strict';

require('angular').module('demo')
    .controller('homeController',[
        '$scope',
        '$interval',
        function ($scope, $interval) {

            function updateTime() {
                var time = new Date();
                $scope.time = time.getHours() + ":" + time.getMinutes() + ":" + time.getSeconds();
            }

            updateTime();

            $interval(updateTime, 250);
        }]);