/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * restricted event names? would be a constructor parameter
// * more argument validation (or remove argument validation, not sure yet)
// * Debounced/asap variations of throttled listener.
// * think about the role of async (publisher? subscriber? always?)

var dict = require("dict");
var emitter = require("./emitter");
var listenerHelpers = require("./listenerHelpers");

Object.keys(listenerHelpers).forEach(function (functionName) {
    exports[functionName] = listenerHelpers[functionName];
});

exports.Publisher = function () {
    var that = this;

    var normalListeners = dict();
    var oneTimeListeners = dict();
    var onSubscriberError = function () { };

    function callListener(listener, args) {
        try {
            listener.apply(null, args);
        } catch (e) {
            onSubscriberError(e);
        }
    }

    function callListenersFor(eventName, args, listenersDict) {
        // .slice() is important to deal with self-unsubscribing listeners
        listenersDict.get(eventName).slice().forEach(function (listener) {
            callListener(listener, args);
        });
    }

    // TODO constructor injection instead of setter injection?
    that.setSubscriberErrorCallback = function (newOnSubscriberError) {
        onSubscriberError = newOnSubscriberError;
    };

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
