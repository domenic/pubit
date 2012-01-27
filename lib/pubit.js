/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

// Still TODO:
// * publisher.mixinEmitter(that)? publish = pubit.makeEmitter(that)?
// * more argument validation (or remove argument validation, not sure yet)

exports.Publisher = require("./Publisher");
exports.throttledListener = require("./listenerHelpers").throttledListener;
exports.debouncedListener = require("./listenerHelpers").debouncedListener;
