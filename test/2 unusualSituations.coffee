require("chai").should()
sinon = require("sinon")

Publisher = require("../lib/pubit").Publisher

describe "Publisher/emitter in unusual situations", ->
    publisher = null
    emitter = null
    fakeError = new Error("OMG it's an error")

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when an event has been subscribed to by two normal handlers plus a handler that removes itself", ->
        normalHandler1 = null
        normalHandler2 = null
        selfRemovingHandler = null

        beforeEach ->
            normalHandler1 = sinon.spy()
            normalHandler2 = sinon.spy()
            selfRemovingHandler = sinon.spy(-> emitter.off("eventName", selfRemovingHandler))

            emitter.on("eventName", normalHandler1)
            emitter.on("eventName", selfRemovingHandler)
            emitter.on("eventName", normalHandler2)

        it "should call all handlers when the event is published once", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(normalHandler1)
            sinon.assert.calledOnce(normalHandler2)
            sinon.assert.calledOnce(selfRemovingHandler)

        it "should only call the normal handlers when the event is published a second time", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            normalHandler1.callCount.should.equal(2)
            normalHandler2.callCount.should.equal(2)
            selfRemovingHandler.callCount.should.equal(1)

    describe "when an event has been subscribed to by two normal handlers plus a handler that throws an error", ->
        normalHandler1 = null
        normalHandler2 = null
        errorThrowingHandler = null

        beforeEach ->
            normalHandler1 = sinon.spy()
            normalHandler2 = sinon.spy()
            errorThrowingHandler = sinon.spy(-> throw fakeError)

            emitter.on("eventName", normalHandler1)
            emitter.on("eventName", errorThrowingHandler)
            emitter.on("eventName", normalHandler2)

        it "should call all handlers when the event is published, despite the error", ->
            publisher.publish("eventName")
            
            sinon.assert.calledOnce(normalHandler1)
            sinon.assert.calledOnce(normalHandler2)
            sinon.assert.calledOnce(errorThrowingHandler)

        it "should deliver the original error to the subscriber error callback when the event is published", ->
            onSubscriberError = sinon.spy()
            publisher.setSubscriberErrorCallback(onSubscriberError)

            publisher.publish("eventName")

            sinon.assert.calledWithExactly(onSubscriberError, fakeError)

    it 'gracefully deals with events named "hasOwnProperty"', ->
        handler = sinon.spy()

        emitter.on("hasOwnProperty", handler)
        publisher.publish("hasOwnProperty")

        sinon.assert.calledOnce(handler)

    it 'gracefully deals with events named "__proto__"', ->
        handler = sinon.spy()

        emitter.on("__proto__", handler)
        publisher.publish("__proto__")

        sinon.assert.calledOnce(handler)
