"use strict";

/**
 * Converts a data uri into a Buffer object, so that it's easier to manipulate within node.
 * @param dataUri
 * @returns {Buffer}
 */
function dataUriToBuffer(dataUri) {
    // separate out the pieces of the uri
    const commaIndex = dataUri.indexOf(',');
    const dataString = dataUri.substring(commaIndex + 1);

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