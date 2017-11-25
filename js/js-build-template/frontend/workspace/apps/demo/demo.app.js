'use strict';

var _ = require('lodash');

console.info('demo.app.js run');

var arr = [1, 2, 3, 4];

_.each(arr, function(elem) {
    console.info(elem);
});