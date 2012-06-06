"use strict";

module.exports = function (chai, utils) {
    chai.Assertion.addMethod("throwArgumentError", function (argName, type) {
        this._obj.should.throw(TypeError, argName + " argument must be a " + type + ".");
    });
};
