"use strict";

var Q = require("q");
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

var slice = Function.prototype.call.bind(Array.prototype.slice);

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

    function callListenerQ(listener, args) {
        try {
            return Q.resolve(listener.apply(null, args));
        } catch (e) {
            return Q.reject(e);
        }
    }

    function callListenersForSync(callListener, args, listeners) {
        var values = [];
        listeners.forEach(function (listener) {
            values.push(callListener(listener, args));
        });
        return values;
    }

    function callListenersForAsync(callListener, args, listeners) {
        process.nextTick(function () {
            callListenersForSync(callListener, args, listeners);
        });
    }

    function callListenersForAsyncQ(callListener, args, listeners) {
        var deferred = Q.defer();
        process.nextTick(function () {
            deferred.resolve(callListenersForSync(callListener, args, listeners));
        });
        return deferred.promise;
    }

    function publishCommon(callListener, callListenersForAsync, eventName) {
        if (typeof eventName !== "string") {
            throw new TypeError("eventName argument must be a string.");
        }
        if (options.events && options.events.indexOf(eventName) === -1) {
            throw new Error('Tried to publish an unknown event "' + eventName + '".');
        }

        var callListenersFor = options.async ? callListenersForAsync : callListenersForSync;
        var args = slice(arguments, 3);
        var listeners = [];

        // .slice() is important to deal with self-unsubscribing listeners
        if (normalListeners.has(eventName)) {
            listeners = listeners.concat(normalListeners.get(eventName).slice());
        }
        if (oneTimeListeners.has(eventName)) {
            listeners = listeners.concat(oneTimeListeners.get(eventName).slice());
            oneTimeListeners.delete(eventName);
        }
        return callListenersFor(callListener, args, listeners);
    }

    that.publish = function () {
        var args = [callListener, callListenersForAsync].concat(slice(arguments, 0));
        publishCommon.apply(null, args);
    };

    that.publish.when = function () {
        var args = [callListenerQ, callListenersForAsyncQ].concat(slice(arguments, 0));
        var promises = publishCommon.apply(null, args);
        return Q.all(promises);
    };

    that.emitter = emitter(normalListeners, oneTimeListeners, options.events);
};
