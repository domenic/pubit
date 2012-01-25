// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * restricted event names? would be a constructor parameter
// * more argument validation
// * Debounced/asap variations of throttled listener.
// * Emitter.once. (Cannot do cleanly as helper since we need to unsubscribe ourselves.)
//   would look like emitter.on("eventName", pubit.oneTimeListener(listener, emitter))
//   vs              emitter.once("eventName", listener)
// * think about the role of async (publisher? subscriber? always?)

"use strict";

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

    // TODO constructor injection instead of setter injection?
    that.setSubscriberErrorCallback = function (newOnSubscriberError) {
        onSubscriberError = newOnSubscriberError;
    };

    that.publish = function (eventName, args) {
        if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
        }

        if (normalListeners.has(eventName)) {
            // .slice() is important to deal with self-unsubscribing listeners
            normalListeners.get(eventName).slice().forEach(function (listener) {
                callListener(listener, args);
            });
        }
        if (oneTimeListeners.has(eventName)) {
            oneTimeListeners.get(eventName).slice().forEach(function (listener) {
                callListener(listener, args);
            });
            oneTimeListeners.delete(eventName);
        }
    };

    that.emitter = emitter(normalListeners, oneTimeListeners);
};
