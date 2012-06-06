"use strict";

exports.throttledListener = function (aggregateListener, waitingPeriod, asap) {
    var pendingTimeout = null;
    var aggregateArgs = [];
    var asapCallHappened = false;

    function onWaitingPeriodElapsed() {
        aggregateListener.call(null, aggregateArgs);
        pendingTimeout = null;
        aggregateArgs = [];
    }

    return function () {
        aggregateArgs.push(arguments[0]);

        if (!pendingTimeout) {
            if (asap && !asapCallHappened) {
                process.nextTick(onWaitingPeriodElapsed);
                asapCallHappened = true;
            } else {
                pendingTimeout = setTimeout(onWaitingPeriodElapsed, waitingPeriod);
            }
        }
    };
};

exports.debouncedListener = function (aggregateListener, waitingPeriod, asap) {
    var pendingTimeout = null;
    var aggregateArgs = [];
    var asapCallHappened = false;

    function onWaitingPeriodElapsed() {
        aggregateListener.call(null, aggregateArgs);
        pendingTimeout = null;
        aggregateArgs = [];
    }

    return function () {
        aggregateArgs.push(arguments[0]);

        if (asap && !asapCallHappened) {
            process.nextTick(onWaitingPeriodElapsed);
            asapCallHappened = true;
        } else {
            clearTimeout(pendingTimeout);
            pendingTimeout = setTimeout(onWaitingPeriodElapsed, waitingPeriod);
        }
    };
};
