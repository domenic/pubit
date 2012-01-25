require("chai").should()
sinon = require("sinon")

Publisher = require("../lib/pubit").Publisher

describe "Publisher/emitter under normal usage", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when an event has been subscribed to", ->
        handler = null

        beforeEach ->
            handler = sinon.spy()
            emitter.subscribe("eventName", handler)

        it "should call the subscribing handler when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(handler)

        it "should call the subscribing handler with the supplied arguments when the event is published with arguments", ->
            publisher.publish("eventName", [1, "foo"])
            
            sinon.assert.calledWithExactly(handler, 1, "foo")

        it "should not call the handler when publishing a different event", ->
            publisher.publish("anotherEvent")

            sinon.assert.notCalled(handler)

        it "should not call the handler when publishing after unsubscribing from the event", ->
            emitter.unsubscribe("eventName", handler)
            publisher.publish("eventName")

            sinon.assert.notCalled(handler)

    describe "when an event has been subscribed to twice by the same handler", ->
        handler = null

        beforeEach ->
            handler = sinon.spy()
            emitter.subscribe("eventName", handler)
            emitter.subscribe("eventName", handler)

        it "should call the subscribing handler twice when the event is published", ->
            publisher.publish("eventName")

            handler.callCount.should.equal(2)

        it "should call the subscribing handler once when the event is unsubscribed from once, then published", ->
            emitter.unsubscribe("eventName", handler)
            publisher.publish("eventName")

            handler.callCount.should.equal(1)

        it "should not call the subscribing handler when the event is unsubscribed from twice, then published", ->
            emitter.unsubscribe("eventName", handler)
            emitter.unsubscribe("eventName", handler)
            publisher.publish("eventName")

            sinon.assert.notCalled(handler)

    describe "when an event has been subscribed to by two different handlers", ->
        handler1 = null
        handler2 = null

        beforeEach ->
            handler1 = sinon.spy()
            handler2 = sinon.spy()

            emitter.subscribe("eventName", handler1)
            emitter.subscribe("eventName", handler2)

        it "should call both handlers when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(handler1)
            sinon.assert.calledOnce(handler2)
        
        it "should call only one handler when the other unsubscribes, then the event is published", ->
            emitter.unsubscribe("eventName", handler1)
            publisher.publish("eventName")

            sinon.assert.notCalled(handler1)
            sinon.assert.calledOnce(handler2)

        it "should call neither handler when the event is blanket-unsubscribed, then published", ->
            emitter.unsubscribe("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(handler1)
            sinon.assert.notCalled(handler2)

    describe "when a hash object mapping event names to handlers is used for subscription", ->
        hash = null

        beforeEach ->
            hash = 
                event1: sinon.spy()
                event2: sinon.spy()
                event3: sinon.spy()
            emitter.subscribe(hash)

        it "publishes events correctly", ->
            publisher.publish("event1")
            publisher.publish("event2")

            sinon.assert.calledOnce(hash.event1)
            sinon.assert.calledOnce(hash.event2)
            sinon.assert.notCalled(hash.event3)

        it "does not publish events when they are mass-unsubscribed using the same hash", ->
            emitter.unsubscribe(hash)

            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event3")

            sinon.assert.notCalled(hash.event1)
            sinon.assert.notCalled(hash.event2)
            sinon.assert.notCalled(hash.event3)
