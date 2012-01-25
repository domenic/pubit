// Still TODO:
// * .mixinEmitter()
// * more argument validation (only subscribe and unsubscribe are covered now)
// * Utility functions (on the module?) for throttled/debounced listening; move subscribeOnce to this style.
// * think about the role of async (publisher? subscriber? always?)

"use strict";

var dict = require("dict");

function isHash(unknown) {
    return typeof unknown === "object" && unknown !== null;
}

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

    function subscribeSingleHandler(eventName, handler) {
        if (!handlerDict.has(eventName)) {
            handlerDict.set(eventName, []);
        }

        handlerDict.get(eventName).push(handler);
    }

    function subscribeMultipleHandlers(hash) {
        Object.keys(hash).forEach(function (eventName) {
            subscribeSingleHandler(eventName, hash[eventName]);
        });
    }

    function unsubscribeSingleHandler(eventName, handler) {
		var handlersArray = handlerDict.get(eventName, []);

		var index = handlersArray.indexOf(handler);
		if (index !== -1) {
	        handlersArray.splice(index, 1);
		}
    }

    function unsubscribeMultipleHandlers(hash) {
        Object.keys(hash).forEach(function (eventName) {
            unsubscribeSingleHandler(eventName, hash[eventName]);
        });
    }

    function unsubscribeAllHandlers(eventName) {
		handlerDict.delete(eventName);
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

	
	that.emitter = {};

    that.emitter.subscribe = function (eventNameOrHash, handler) {
        if (arguments.length === 1) {
            if (!isHash(eventNameOrHash)) {
                throw new TypeError("hash argument must be a string-to-function hash.");
            }

            subscribeMultipleHandlers(eventNameOrHash);
        } else {
            if (typeof eventNameOrHash !== "string") {
                throw new TypeError("eventName argument must be a string.");
            }
            if (typeof handler !== "function") {
                throw new TypeError("handler argument must be a function.");
            }
            subscribeSingleHandler(eventNameOrHash, handler);
        }
    };

    that.emitter.unsubscribe = function (eventNameOrHash, handler) {
        if (typeof eventNameOrHash === "string") {
            if (typeof handler === "undefined") {
                unsubscribeAllHandlers(eventNameOrHash);
            } else if (typeof handler === "function") {
                unsubscribeSingleHandler(eventNameOrHash, handler);
            } else {
                throw new TypeError("handler argument must be a function.");
            }
        } else if (isHash(eventNameOrHash)) {
            unsubscribeMultipleHandlers(eventNameOrHash);
        } else {
            if (arguments.length === 2) {
                throw new TypeError("eventName argument must be a string.");
            } else {
                throw new TypeError("eventNameOrHash argument must be a string or string-to-function hash.");
            }
        }
    };
};
