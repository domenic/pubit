pubit = require("../lib/pubit-as-promised")

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
        listener1.should.have.been.called

        publish("event2")
        publish("event2")
        listener2.should.have.been.calledOnce

        target.off("event3")
        publish("event3")
        listener3.should.not.have.been.called

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

        (-> publish("anotherEvent").catch(->)).should.throw()
        (-> target.on("anotherEvent")).should.throw()

        publish("event").catch(->)
        listener.should.not.have.been.called
        process.nextTick ->
            listener.should.have.been.called
            onListenerError.should.have.been.calledWith(error)
            next()
