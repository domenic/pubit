/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * restricted event names? would be a constructor parameter
// * more argument validation (or remove argument validation, not sure yet)
// * think about the role of async (publisher? subscriber? always?)

var dict = require("dict");
var emitter = require("./emitter");
var listenerHelpers = require("./listenerHelpers");

Object.keys(listenerHelpers).forEach(function (functionName) {
    exports[functionName] = listenerHelpers[functionName];
});

function normalizeOptions(options) {
    if (typeof options !== "object" || options === null) {
        throw new TypeError("options argument must be an object.");
    }

    if (options.onListenerError === undefined) {
        options.onListenerError = function () { };
    }

    if (typeof options.onListenerError !== "function") {
        throw new TypeError("options.onListenerError must be an object.");
    }

    return options;
}

exports.Publisher = function (options) {
    var that = this;

    var normalListeners = dict();
    var oneTimeListeners = dict();

    if (options === undefined) {
        options = {};
    }
    normalizeOptions(options);

    function callListener(listener, args) {
        try {
            listener.apply(null, args);
        } catch (e) {
            options.onListenerError(e);
        }
    }

    function callListenersFor(eventName, args, listenersDict) {
        // .slice() is important to deal with self-unsubscribing listeners
        listenersDict.get(eventName).slice().forEach(function (listener) {
            callListener(listener, args);
        });
    }

    that.publish = function (eventName, args) {
        if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
        }

        if (normalListeners.has(eventName)) {
            callListenersFor(eventName, args, normalListeners);
        }
        if (oneTimeListeners.has(eventName)) {
            callListenersFor(eventName, args, oneTimeListeners);
            oneTimeListeners.delete(eventName);
        }
    };

    that.emitter = emitter(normalListeners, oneTimeListeners);
};
