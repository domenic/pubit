// Still TODO:
// * .mixinEmitter()
// * more argument validation (only subscribe and unsubscribe are covered now)
// * Utility functions (on the module?) for throttled/debounced listening; move subscribeOnce to this style.
// * think about the role of async (publisher? subscriber? always?)

"use strict";

var dict = require("dict");
var emitter = require("./emitter");

exports.Publisher = function () {
    var that = this;

    var handlerDict = dict();
    var onSubscriberError = function () { };

    function callHandler(handler, args) {
        try {
            handler.apply(null, args);
        } catch (e) {
            onSubscriberError(e);
        }
    }

    // TODO constructor injection instead of setter injection?
    that.setSubscriberErrorCallback = function (newOnSubscriberError) {
        onSubscriberError = newOnSubscriberError;
    };

    that.publish = function (eventName, args) {
        if (handlerDict.has(eventName)) {
            var errorsThrown = [];

            // .slice() is important to deal with self-unsubscribing handlers
            handlerDict.get(eventName).slice().forEach(function (handler) {
                callHandler(handler, args);
            });
        }
    };

    
    that.emitter = emitter(handlerDict);
};
