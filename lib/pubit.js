/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * more argument validation (or remove argument validation, not sure yet)

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

    if (options.events !== undefined && !Array.isArray(options.events)) {
        throw new TypeError("options.events must be an array.");
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

    that.publish = function (eventName, args) {
        if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
        }
        if (options.events && options.events.indexOf(eventName) === -1) {
            throw new Error('Tried to publish an unknown event "' + eventName + '".');
        }

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
