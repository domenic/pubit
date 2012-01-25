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
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.on("eventName", listener)

        it "should call the subscribing listener when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener)

        it "should call the subscribing listener with the supplied arguments when the event is published with arguments", ->
            publisher.publish("eventName", [1, "foo"])
            
            sinon.assert.calledWithExactly(listener, 1, "foo")

        it "should not call the listener when publishing a different event", ->
            publisher.publish("anotherEvent")

            sinon.assert.notCalled(listener)

        it "should not call the listener when publishing after unsubscribing from the event", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

    describe "when an event has been subscribed to twice by the same listener", ->
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.on("eventName", listener)
            emitter.on("eventName", listener)

        it "should call the subscribing listener twice when the event is published", ->
            publisher.publish("eventName")

            listener.callCount.should.equal(2)

        it "should call the subscribing listener once when the event is unsubscribed from once, then published", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            listener.callCount.should.equal(1)

        it "should not call the subscribing listener when the event is unsubscribed from twice, then published", ->
            emitter.off("eventName", listener)
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

        it "should not call the subscribing listener when the event is blanket-unsubscribed, then published", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

    describe "when an event has been subscribed to by two different listeners", ->
        listener1 = null
        listener2 = null

        beforeEach ->
            listener1 = sinon.spy()
            listener2 = sinon.spy()

            emitter.on("eventName", listener1)
            emitter.on("eventName", listener2)

        it "should call both listeners when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener1)
            sinon.assert.calledOnce(listener2)
        
        it "should call only one listener when the other unsubscribes, then the event is published", ->
            emitter.off("eventName", listener1)
            publisher.publish("eventName")

            sinon.assert.notCalled(listener1)
            sinon.assert.calledOnce(listener2)

        it "should call neither listener when the event is blanket-unsubscribed, then published", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(listener1)
            sinon.assert.notCalled(listener2)

    describe "when a hash object mapping event names to listeners is used for subscription", ->
        hash = null

        beforeEach ->
            hash = 
                event1: sinon.spy()
                event2: sinon.spy()
                event3: sinon.spy()
            emitter.on(hash)

        it "publishes events correctly", ->
            publisher.publish("event1")
            publisher.publish("event2")

            sinon.assert.calledOnce(hash.event1)
            sinon.assert.calledOnce(hash.event2)
            sinon.assert.notCalled(hash.event3)

        it "does not publish events when they are mass-unsubscribed using the same hash", ->
            emitter.off(hash)

            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event3")

            sinon.assert.notCalled(hash.event1)
            sinon.assert.notCalled(hash.event2)
            sinon.assert.notCalled(hash.event3)
