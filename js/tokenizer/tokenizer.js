/**
 * Created by Tydaeus on 9/28/2015.
 */

var TokenDefinition = require("./TokenDefinition").TokenDefinition;
var Token = require("./Token").Token;


function Tokenizer() {
    this.tokenDefinitionsMap = {};
    this.tokenDefinitions = [];
    this.listeners = [];
}

Tokenizer.prototype = { };


/**
 * registers a new listener
 * @param listener {Function} the new listener to be registered; this should be
 * of form function(Token)
 */
Tokenizer.prototype.addListener = function addListener(listener) {
    this.listeners.push(listener);
};

Tokenizer.prototype.notifyListeners = function notifyListeners(token) {
    for (var i = 0; i < this.listeners.length; i++) {
        this.listeners[i](token);
    }
};

/**
 * Creates a new token named [name] if none exists, otherwise displays a
 * warning and retrieves the existing named token
 * @param name the name of the TokenDefinition to be created or retrieved
 * @returns {TokenDefinition} the TokenDefinition with the provided name
 */
Tokenizer.prototype.defineToken = function defineToken(name) {
    if (!this.tokenDefinitionsMap[name]) {
        this.tokenDefinitionsMap[name] = new TokenDefinition(name);
        this.tokenDefinitions.push(this.tokenDefinitionsMap[name]);
    } else {
        console.warn("token '" + name + "' already defined");
    }
    return this.tokenDefinitionsMap[name];
};

/**
 * prints a user-readable listing of all current token definitions
 */
Tokenizer.prototype.listTokenDefinitions = function listTokenDefinitions() {
    console.log("Tokens: ");
    var info;
    for (var i in this.tokenDefinitions) {
        info = "\t";
        if (this.tokenDefinitions[i].matcher === TokenDefinition.defaultMatcher) {
            info += "no matcher defined";
        } else {
            info += this.tokenDefinitions[i].matcher;
        }
        console.log("\t'" + this.tokenDefinitions[i].name + "'" + info);
    }
};

/**
 * checks str against all token definitions
 * @param str {String} string to check against all definitions
 * @returns {TokenDefinition[]} all matching definitions
 */
Tokenizer.prototype.evaluateDefinitions = function evaluateDefinitions(str) {
    var result = [];
    for (var i = 0; i < this.tokenDefinitions.length; i++) {
        if (this.tokenDefinitions[i].match(str)) {
            result.push(this.tokenDefinitions[i]);
        }
    }
    return result;
};

Tokenizer.prototype.tokenize = function tokenize(str) {
    var curToken = new Token();
    var currentMatches, lookaheadMatches, i, j;
    var result = [];

    var self = this;

    function saveToken() {
        curToken.type = currentMatches[0].name;
        result.push(curToken);
        self.notifyListeners(curToken);
        curToken = new Token();
    }

    for (i = 0; i < str.length; i++) {
        curToken.value = curToken.value + str.charAt(i);
        currentMatches = self.evaluateDefinitions(curToken.value);

        if (i + 1 < str.length) {
            lookaheadMatches = self.evaluateDefinitions(curToken.value + str.charAt(i + 1));
        } else {
            lookaheadMatches = [];
        }

        if (currentMatches.length > 0 && lookaheadMatches.length === 0) {

            if (currentMatches.length > 1) {
                var ruleNames = "";
                for (j = 0; j < currentMatches.length; j++) {
                    if (j > 0) {
                        ruleNames += ", ";
                    }
                    ruleNames += "'" + currentMatches[j].name + "'";
                }
                console.error("Ambiguous matching rules defined; rules " + ruleNames + " all match '" +
                    curToken.value + "', using first rule.");
            }

            saveToken();
        } else if (currentMatches.length === 0) {
            console.warn("Non-matching pattern '" + curToken.value + "' encountered; ruleset may be incomplete");
        }

    }

    if (curToken.value) {
        console.error("Partial token left over after tokenization: '" + curToken.value + "'");
    }

    return result;
};

exports.Tokenizer = Tokenizer;