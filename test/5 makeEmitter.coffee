sinon = require("sinon")
expect = require("chai").expect
should = require("chai").should()

pubit = require("../lib/pubit")

describe "makeEmitter", ->
    target = null
    
    beforeEach ->
        target = {}

    it "should return a publish method and mixin an emitter", ->
        publish = pubit.makeEmitter(target)

        listener1 = sinon.spy()
        listener2 = sinon.spy()
        listener3 = sinon.spy()

        target.on("event1", listener1)
        target.onNext("event2", listener2)
        target.on("event3", listener3)

        publish("event1")
        sinon.assert.called(listener1)

        publish("event2")
        publish("event2")
        sinon.assert.calledOnce(listener2)

        target.off("event3")
        publish("event3")
        sinon.assert.notCalled(listener3)

    it "should mixin the emitter methods as non-enumerable properties", ->
        pubit.makeEmitter(target)

        Object.getOwnPropertyDescriptor(target, "on").enumerable.should.be.false
        Object.getOwnPropertyDescriptor(target, "onNext").enumerable.should.be.false
        Object.getOwnPropertyDescriptor(target, "off").enumerable.should.be.false

    it "should use the options passed in", (next) ->
        onListenerError = sinon.spy()
        publish = pubit.makeEmitter(target, events: ["event"], async: true, onListenerError: onListenerError)

        listener = sinon.spy()
        target.on("event", listener)

        error = new Error("boo!")
        errorThrowingListener = -> throw error
        target.on("event", errorThrowingListener)

        expect(-> publish("anotherEvent")).to.throw()
        expect(-> target.on("anotherEvent")).to.throw()

        publish("event")
        sinon.assert.notCalled(listener)
        process.nextTick ->
            sinon.assert.called(listener)
            sinon.assert.calledWith(onListenerError, error)
            next()
