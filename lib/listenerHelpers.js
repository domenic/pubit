/*jshint curly: true, eqeqeq: true, immed: true, latedef: true, newcap: true, noarg: true, nonew: true, trailing: true, undef: true, white: true, es5: true, globalstrict: true, node: true */
"use strict";

exports.throttledListener = function (aggregateListener, waitingPeriod) {
    var pendingTimeout = null;
    var aggregateArgs = [];

    return function () {
        aggregateArgs.push(arguments[0]);

        if (!pendingTimeout) {
            pendingTimeout = setTimeout(function () {
                aggregateListener.call(null, aggregateArgs);
                pendingTimeout = null;
                aggregateArgs = [];
            }, waitingPeriod);
        }
    };
};
