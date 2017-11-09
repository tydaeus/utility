/**
 * Created by Tydaeus on 10/17/2015.
 */
function TokenDefinition(name) {
    this._name = name;
    this.matcher = TokenDefinition.defaultMatcher;
}

TokenDefinition.defaultMatcher = function () {
    return false;
};

TokenDefinition.prototype = {
    get name() {
        return this._name;
    },

    set matcher(val) {
        if (val === undefined || val === null) {
            console.warn("Matcher function for '" + this.name + "' set to inappropriate value, using fail through " +
                "matcher");
            this._matcher = TokenDefinition.defaultMatcher;
        }
        else if (val instanceof Function || val instanceof RegExp || typeof val === "string") {
            this._matcher = val;
        } else {
            this._matcher = String(val);
        }
    },
    get matcher() {
        return this._matcher;
    },
    setMatcher: function(val) {
        this.matcher = val;
        return this;
    },
    getMatcher: function() {
        return this.matcher;
    },

    match: function(val) {
        if (this.matcher instanceof Function) {
            return this.matcher(val);
        } else if (this.matcher instanceof RegExp) {
            return this.matcher.test(val);
        } else if (typeof this.matcher === "string") {
            return this.matcher === val;
        } else {
            throw new TypeError("matcher not function, regex, or string")
        }
    }
};

exports.TokenDefinition = TokenDefinition;