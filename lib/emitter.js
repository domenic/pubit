"use strict";

function isHash(unknown) {
    return typeof unknown === "object" && unknown !== null;
}

module.exports = function emitter(listeners) {
    function subscribeSingleListener(eventName, listener) {
        if (!listeners.has(eventName)) {
            listeners.set(eventName, []);
        }

        listeners.get(eventName).push(listener);
    }

    function subscribeMultipleListeners(hash) {
        Object.keys(hash).forEach(function (eventName) {
            subscribeSingleListener(eventName, hash[eventName]);
        });
    }

    function unsubscribeSingleListener(eventName, listener) {
        var listenersArray = listeners.get(eventName, []);

        var index = listenersArray.indexOf(listener);
        if (index !== -1) {
            listenersArray.splice(index, 1);
        }
    }

    function unsubscribeMultipleListeners(hash) {
        Object.keys(hash).forEach(function (eventName) {
            unsubscribeSingleListener(eventName, hash[eventName]);
        });
    }

    function unsubscribeAllListeners(eventName) {
        listeners.delete(eventName);
    }
    
    return {
        on: function (eventNameOrHash, listener) {
            if (arguments.length === 1) {
                if (!isHash(eventNameOrHash)) {
                    throw new TypeError("hash argument must be a string-to-function hash.");
                }

                subscribeMultipleListeners(eventNameOrHash);
            } else {
                if (typeof eventNameOrHash !== "string") {
                    throw new TypeError("eventName argument must be a string.");
                }
                if (typeof listener !== "function") {
                    throw new TypeError("listener argument must be a function.");
                }
                subscribeSingleListener(eventNameOrHash, listener);
            }
        },
        off: function (eventNameOrHash, listener) {
            if (typeof eventNameOrHash === "string") {
                if (typeof listener === "undefined") {
                    unsubscribeAllListeners(eventNameOrHash);
                } else if (typeof listener === "function") {
                    unsubscribeSingleListener(eventNameOrHash, listener);
                } else {
                    throw new TypeError("listener argument must be a function.");
                }
            } else if (isHash(eventNameOrHash)) {
                unsubscribeMultipleListeners(eventNameOrHash);
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
