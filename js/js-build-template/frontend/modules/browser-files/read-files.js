function readFiles(fileList, method) {
    var promises = [];
    for (var i = 0; i < fileList.length; i++) {
        promises.push(readFile(fileList[i], method));
    }

    return Promise.all(promises);
}

function readFile(file, method) {
    return new Promise(function(resolve, reject) {
        var fileReader = new FileReader();

        fileReader.onloadend = function(e) {
            file.data = e.target.result;
            resolve(file);
        };

        fileReader.onerror = reject;

        if (!method || method === "arrayBuffer") {
            fileReader.readAsArrayBuffer(file);
        } else if (method === "text") {
            fileReader.readAsText(file);
        } else if (method === "dataURL") {
            fileReader.readAsDataURL(file);
        }
    });
}

module.exports = readFiles;
