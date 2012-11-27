"use strict";

function isHash(unknown) {
    return typeof unknown === "object" && unknown !== null;
}

var SEPARATOR = " ";

module.exports = function emitter(normalListeners, oneTimeListeners, events) {

    function subscribeSingleListener(eventName, listener, listeners) {
        if (events && events.indexOf(eventName) === -1) {
            throw new Error('Tried to subscribe to an unknown event "' + eventName + '".');
        }

        if (!listeners.has(eventName)) {
            listeners.set(eventName, []);
        }

        listeners.get(eventName).push(listener);

        return function unsubscribe() {
            unsubscribeSingleListener(eventName, listener, listeners);
        };
    }

    function subscribeMultipleListeners(hash, listeners) {
        Object.keys(hash).forEach(function (eventName) {
            subscribeSingleListener(eventName, hash[eventName], listeners);
        });
        return function unsubscribe() {
            unsubscribeMultipleListeners(hash, listeners);
        };
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

            return subscribeMultipleListeners(eventNameOrHash, listeners);
        } else {
            if (typeof eventNameOrHash !== "string") {
                throw new TypeError("eventName argument must be a string.");
            }
            if (typeof listener !== "function") {
                throw new TypeError("listener argument must be a function.");
            }

            var unsubscribers = eventNameOrHash.split(SEPARATOR)
            .map(function (eventName) {
                return subscribeSingleListener(eventName, listener, listeners);
            });

            return function unsubscribe() {
                unsubscribers.forEach(function (unsubscribe) {
                    unsubscribe();
                });
            };
        }
    }

    return {
        on: function (eventNameOrHash, listener) {
            return onImpl(eventNameOrHash, listener, normalListeners);
        },
        onNext: function (eventNameOrHash, listener) {
            return onImpl(eventNameOrHash, listener, oneTimeListeners);
        },
        off: function (eventNameOrHash, listener) {
            if (typeof eventNameOrHash === "string") {
                if (typeof listener === "undefined") {
                    eventNameOrHash.split(SEPARATOR).forEach(function (eventName) {
                        unsubscribeAllListeners(eventName, normalListeners);
                        unsubscribeAllListeners(eventName, oneTimeListeners);
                    });
                } else if (typeof listener === "function") {
                    eventNameOrHash.split(SEPARATOR).forEach(function (eventName) {
                        unsubscribeSingleListener(eventName, listener, normalListeners);
                        unsubscribeSingleListener(eventName, listener, oneTimeListeners);
                    });
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
