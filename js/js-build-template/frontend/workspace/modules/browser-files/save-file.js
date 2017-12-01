"use strict";

var _ = require('underscore');

var defaults = {
    data: "",
    name: "untitled"
};

function saveFile(fileInfo) {
    fileInfo = _.extend({}, saveFile.defaults, fileInfo);

    var element = document.createElement("a");
    element.setAttribute('href', fileInfo.data);
    element.setAttribute('download', fileInfo.name);

    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}

// to convert text into saveable data, must set data to:
// 'data:text/plain;charset=utf-8,' + encodeURIComponent(fileInfo.data)


saveFile.defaults = defaults;

module.exports = saveFile;
