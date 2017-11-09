/**
 * Created by Tydaeus on 10/24/2015.
 */

function Token () {
    this._type = "";
    this._value = "";
}

Token.prototype = {
    set type(val) {
        this._type = val;
    },
    get type() {
        return this._type;
    },
    set value(val) {
        this._value = val;
    },
    get value() {
        return this._value;
    }
};

exports.Token = Token;