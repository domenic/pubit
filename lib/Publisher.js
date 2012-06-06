"use strict";

var dict = require("dict");
var emitter = require("./emitter");

function normalizeOptions(options) {
    if (typeof options !== "object" || options === null) {
        throw new TypeError("options argument must be an object or array of events.");
    }

    if (Array.isArray(options)) {
        options = { events: options };
    }

    if (options.onListenerError === undefined) {
        options.onListenerError = function (error) {
            process.nextTick(function () {
                throw error;
            });
        };
    }

    if (typeof options.onListenerError !== "function") {
        throw new TypeError("options.onListenerError must be an object.");
    }

    if (options.events !== undefined && !Array.isArray(options.events)) {
        throw new TypeError("options.events must be an array.");
    }

    return options;
}

var slice = (function () {
    var bind = Function.prototype.bind;
    var uncurryThis = bind.bind(bind.call);

    return uncurryThis(Array.prototype.slice);
}());

module.exports = function Publisher(options) {
    var that = this;

    var normalListeners = dict();
    var oneTimeListeners = dict();

    if (options === undefined) {
        options = {};
    }
    options = normalizeOptions(options);

    function callListener(listener, args) {
        try {
            listener.apply(null, args);
        } catch (e) {
            options.onListenerError(e);
        }
    }

    function callListenersForSync(eventName, args, listenersDict) {
        // .slice() is important to deal with self-unsubscribing listeners
        listenersDict.get(eventName).slice().forEach(function (listener) {
            callListener(listener, args);
        });
    }

    function callListenersForAsync(eventName, args, listenersDict) {
        process.nextTick(function () {
            callListenersForSync(eventName, args, listenersDict);
        });
    }

    var callListenersFor = options.async ? callListenersForAsync : callListenersForSync;

    that.publish = function (eventName) {
        if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
        }
        if (options.events && options.events.indexOf(eventName) === -1) {
            throw new Error('Tried to publish an unknown event "' + eventName + '".');
        }

        var args = slice(arguments, 1);

        if (normalListeners.has(eventName)) {
            callListenersFor(eventName, args, normalListeners);
        }
        if (oneTimeListeners.has(eventName)) {
            callListenersFor(eventName, args, oneTimeListeners);
            oneTimeListeners.delete(eventName);
        }
    };

    that.emitter = emitter(normalListeners, oneTimeListeners, options.events);
};
