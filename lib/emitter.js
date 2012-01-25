"use strict";

function isHash(unknown) {
    return typeof unknown === "object" && unknown !== null;
}

module.exports = function emitter(handlerDict) {
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
    
    return {
        subscribe: function (eventNameOrHash, handler) {
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
        },
        unsubscribe: function (eventNameOrHash, handler) {
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
        }
    };
};