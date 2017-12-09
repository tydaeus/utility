/* global document */
function pickFiles() {
    return new Promise(function(resolve, reject) {
        var elem = document.createElement('input');
        elem.setAttribute('type', 'file');
        elem.setAttribute('style', 'display:none');
        elem.setAttribute('multiple', 'true');
        // can setAttribute 'accept' to a comma-separated list of mime types or extensions to restrict
        elem.onchange = function() { resolve(elem.files); };

        setTimeout(function() {
            elem.click();
        }, 0);

    });
}

module.exports = pickFiles;
