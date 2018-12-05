"use strict";

function dataUriToBuffer(dataUri) {
    // separate out the pieces of the uri
    const commaIndex = dataUri.indexOf(',');
    const dataString = dataUri.substring(commaIndex + 1);
    const prefixString = dataUri.substring(0, commaIndex);
    const mimeString = prefixString.split(':')[1].split(';')[0];

    const byteString = atob(dataString);
    const arrayBuffer = new ArrayBuffer(byteString.length);
    const intArrayView = new Uint8Array(arrayBuffer);

    // copy bytes into Uint8Array
    for (let i = 0; i < byteString.length; i++) {
        intArrayView[i] = byteString.charCodeAt(i);
    }

    // make a buffer from the array
    return Buffer.from(arrayBuffer);
}

module.exports = dataUriToBuffer;