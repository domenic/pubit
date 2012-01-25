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
