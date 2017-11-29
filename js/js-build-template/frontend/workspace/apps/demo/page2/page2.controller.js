'use strict';

require('angular')
    .module('demo')
    .controller('page2Controller', [
        '$scope',
        function ($scope) {
            $scope.loadFiles = function() {
                var elem = document.createElement('input');
                elem.setAttribute('type', 'file');
                elem.setAttribute('style', 'display:none');
                elem.setAttribute('multiple', 'true');
                // can setAttribute 'accept' to a comma-separated list of mime types or extensions to restrict
                elem.onchange = function() { filesSelected(elem.files); };
                // document.appendChild(elem);
                elem.click();
                // document.removeChild(elem);
            };

            function filesSelected(files) {
                console.info(files);
            }

            // todo: read uploaded files
            function readFile(file) {
                var fileReader = new FileReader();
                fileReader.onloadend = function(e) {
                    deferred.resolve(e.target.result);
                };

                if (!method || method === "arrayBuffer") {
                    fileReader.readAsArrayBuffer(file);
                } else if (method === "text") {
                    fileReader.readAsText(file);
                } else if (method === "dataURL") {
                    fileReader.readAsDataURL(file);
                }
            }
        }]);