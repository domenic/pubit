Publisher = require("../lib/pubit").Publisher

describe "Publisher options", ->
    publisher = null
    emitter = null

    describe "onListenerError", ->
        it "should by default re-throw listeners errors in the next turn of the event loop", (next) ->
            publisher = new Publisher()
            emitter = publisher.emitter

            error = new Error("Boo")
            emitter.on("eventName", -> throw error)

            onUncaughtException = sinon.spy()
            originalOnUncaughtException = process.listeners("uncaughtException").pop()
            process.once("uncaughtException", onUncaughtException)

            publisher.publish("eventName")

            process.nextTick ->
                process.listeners("uncaughtException").push(originalOnUncaughtException)
                sinon.assert.calledWith(onUncaughtException, error)
                next()

        it "should deliver errors thrown by listeners to the supplied callback", ->
            onListenerError = sinon.spy()
            publisher = new Publisher(onListenerError: onListenerError)
            emitter = publisher.emitter

            error = new Error("Boo")
            emitter.on("eventName", -> throw error)

            publisher.publish("eventName")

            sinon.assert.calledWith(onListenerError, error)

    describe "async", ->
        beforeEach ->
            publisher = new Publisher(async: true)
            emitter = publisher.emitter

        it "should result in events being published asynchronously", (next) ->
            listener1 = sinon.spy()
            listener2 = sinon.spy()
            emitter.on("event1", listener1)
            emitter.on("event2", listener2)

            publisher.publish("event1")
            publisher.publish("event2")

            sinon.assert.notCalled(listener1)
            sinon.assert.notCalled(listener2)

            process.nextTick ->
                sinon.assert.called(listener1)
                sinon.assert.called(listener2)
                next()

    describe "events", ->
        beforeEach ->
            publisher = new Publisher(events: ["event1", "event2"])
            emitter = publisher.emitter

        it "should publish the supplied events as usual", ->
            listener1 = sinon.spy()
            listener2 = sinon.spy()
            emitter.on("event1", listener1)
            emitter.on("event2", listener2)

            publisher.publish("event1")
            publisher.publish("event2")

            sinon.assert.called(listener1)
            sinon.assert.called(listener2)

        it "should throw an error upon attempting to subscribe to an unknown event", ->
            (-> emitter.on("unknownEvent", ->)).should.throw()

        it "should throw an error upon attempting to publish an unknown event", ->
            (-> publisher.publish("unknownEvent")).should.throw()

    it "should be validated", ->
        (-> new Publisher(null)).should.throw(TypeError)
        (-> new Publisher(5)).should.throw(TypeError)
        (-> new Publisher("hi")).should.throw(TypeError)
        (-> new Publisher(->)).should.throw(TypeError)

        (-> new Publisher(onListenerError: null)).should.throw(TypeError)
        (-> new Publisher(onListenerError: {})).should.throw(TypeError)
        (-> new Publisher(onListenerError: 5)).should.throw(TypeError)

        (-> new Publisher(events: null)).should.throw(TypeError)
        (-> new Publisher(events: {})).should.throw(TypeError)
        (-> new Publisher(events: 5)).should.throw(TypeError)
