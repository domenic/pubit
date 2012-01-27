/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

function isHash(unknown) {
    return typeof unknown === "object" && unknown !== null;
}

module.exports = function emitter(normalListeners, oneTimeListeners, events) {
    function subscribeSingleListener(eventName, listener, listeners) {
        if (events && events.indexOf(eventName) === -1) {
            throw new Error('Tried to subscribe to an unknown event "' + eventName + '".');
        }

        if (!listeners.has(eventName)) {
            listeners.set(eventName, []);
        }

        listeners.get(eventName).push(listener);
    }

    function subscribeMultipleListeners(hash, listeners) {
        Object.keys(hash).forEach(function (eventName) {
            subscribeSingleListener(eventName, hash[eventName], listeners);
        });
    }

    function unsubscribeSingleListener(eventName, listener, listeners) {
        var listenersArray = listeners.get(eventName, []);

        var index = listenersArray.indexOf(listener);
        if (index !== -1) {
            listenersArray.splice(index, 1);
        }
    }

    function unsubscribeMultipleListeners(hash, listeners) {
        Object.keys(hash).forEach(function (eventName) {
            unsubscribeSingleListener(eventName, hash[eventName], listeners);
        });
    }

    function unsubscribeAllListeners(eventName, listeners) {
        listeners.delete(eventName);
    }

    function onImpl(eventNameOrHash, listener, listeners) {
        if (listener === undefined) {
            if (!isHash(eventNameOrHash)) {
                throw new TypeError("hash argument must be a string-to-function hash.");
            }

            subscribeMultipleListeners(eventNameOrHash, listeners);
        } else {
            if (typeof eventNameOrHash !== "string") {
                throw new TypeError("eventName argument must be a string.");
            }
            if (typeof listener !== "function") {
                throw new TypeError("listener argument must be a function.");
            }
            subscribeSingleListener(eventNameOrHash, listener, listeners);
        }
    }
    
    return {
        on: function (eventNameOrHash, listener) {
            onImpl(eventNameOrHash, listener, normalListeners);
        },
        onNext: function (eventNameOrHash, listener) {
            onImpl(eventNameOrHash, listener, oneTimeListeners);
        },
        off: function (eventNameOrHash, listener) {
            if (typeof eventNameOrHash === "string") {
                if (typeof listener === "undefined") {
                    unsubscribeAllListeners(eventNameOrHash, normalListeners);
                    unsubscribeAllListeners(eventNameOrHash, oneTimeListeners);
                } else if (typeof listener === "function") {
                    unsubscribeSingleListener(eventNameOrHash, listener, normalListeners);
                    unsubscribeSingleListener(eventNameOrHash, listener, oneTimeListeners);
                } else {
                    throw new TypeError("listener argument must be a function.");
                }
            } else if (isHash(eventNameOrHash)) {
                unsubscribeMultipleListeners(eventNameOrHash, normalListeners);
                unsubscribeMultipleListeners(eventNameOrHash, oneTimeListeners);
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
