/*jshint
 curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true,
 undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

exports.Publisher = require("./Publisher");
exports.throttledListener = require("./listenerHelpers").throttledListener;
exports.debouncedListener = require("./listenerHelpers").debouncedListener;

exports.makeEmitter = function (target, options) {
    var publisher = new exports.Publisher(options);

    Object.getOwnPropertyNames(publisher.emitter).forEach(function (methodName) {
        Object.defineProperty(target, methodName, {
            value: publisher.emitter[methodName],
            configurable: true,
            writable: true,
            enumerable: false
        });
    });

    return publisher.publish;
};
