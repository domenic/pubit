sinon = require("sinon")
expect = require("chai").expect

Publisher = require("../lib/pubit").Publisher

describe "Publisher options", ->
    publisher = null
    emitter = null

    describe "onListenerError", ->
        onListenerError = null

        beforeEach ->
            onListenerError = sinon.spy()
            publisher = new Publisher(onListenerError: onListenerError)
            emitter = publisher.emitter

        it "should deliver errors thrown by listeners to the supplied callback", ->
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

    it "should be validated", ->
        expect(-> new Publisher(null)).to.throw(TypeError)
        expect(-> new Publisher(5)).to.throw(TypeError)
        expect(-> new Publisher("hi")).to.throw(TypeError)
        expect(-> new Publisher(->)).to.throw(TypeError)

        expect(-> new Publisher(onListenerError: null)).to.throw(TypeError)
        expect(-> new Publisher(onListenerError: {})).to.throw(TypeError)
        expect(-> new Publisher(onListenerError: 5)).to.throw(TypeError)
