sinon = require("sinon")

Publisher = require("../lib/pubit").Publisher

describe "emitter.onNext", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when passed a single listener for a single event", ->
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.onNext("eventName", listener)

        it "should call the listener when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener)

        it "should not call the listener when the event is published a second time", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener)

        it "should not call the listener when the event is unsubscribed from before ever being published", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

        it "should not call the listener when the event is blanket-unsubscribed from before ever being published", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

    describe "when called twice, with two different listeners, but for the same event", ->
        listener1 = null
        listener2 = null

        beforeEach ->
            listener1 = sinon.spy()
            listener2 = sinon.spy()
            emitter.onNext("eventName", listener1)
            emitter.onNext("eventName", listener2)

        it "should call both listeners when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener1)
            sinon.assert.calledOnce(listener2)

        it "should not call either listener when the event is published a second time", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener1)
            sinon.assert.calledOnce(listener2)

    describe "when called twice, with the same listener, for the same event", ->
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.onNext("eventName", listener)
            emitter.onNext("eventName", listener)

        it "should call the listener twice when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledTwice(listener)

        it "should not call the listener when the event is published a second time", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            sinon.assert.calledTwice(listener)

        # This is different from emitter.on.
        it "should not call the listener at all when the event is unsubscribed from", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

    describe "when used in conjunction with emitter.on for the same listener", ->
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.onNext("eventName", listener)
            emitter.on("eventName", listener)

        it "should call the listener twice when the event is published", ->
            publisher.publish("eventName")

            sinon.assert.calledTwice(listener)

        it "should call the listener a total of three times when the event is published twice", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            sinon.assert.calledThrice(listener)

        it "should not call the listener at all when the event is unsubscribed from", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

        it "should not call the listener at all when the event is blanket-unsubscribed from", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            sinon.assert.notCalled(listener)

        it "should call the listener once if emitter.on is used again and then the event unsubscribed from", ->
            emitter.on("eventName", listener)
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            sinon.assert.calledOnce(listener)

    describe "when three events are subscribed to in one call", ->
        events = ["event1", "event2", "event3"]
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.onNext(events.join(" "), listener)

        it "publishes the first event correctly, and the listener is called only the first time", ->
            publisher.publish("event1")
            publisher.publish("event1")

            sinon.assert.calledOnce(listener)

        it "publishes the second event correctly, and the listener is called only the first time", ->
            publisher.publish("event2")
            publisher.publish("event2")

            sinon.assert.calledOnce(listener)

        it "publishes the third event correctly, and the listener is called only the first time", ->
            publisher.publish("event3")
            publisher.publish("event3")

            sinon.assert.calledOnce(listener)

        it "unsubscribes from two events at once correctly, when passed the listener explicitly", ->
            emitter.off("event2 event3", listener)
            publisher.publish("event2")
            publisher.publish("event3")

            sinon.assert.notCalled(listener)

        it "unsubscribes from two events at once correctly, when doing blanket unsubscription", ->
            emitter.off("event2 event3")
            publisher.publish("event2")
            publisher.publish("event3")

            sinon.assert.notCalled(listener)

    describe "when a hash object mapping event names to listeners is used for subscription", ->
        hash = null

        beforeEach ->
            hash = 
                event1: sinon.spy()
                event2: sinon.spy()
                event3: sinon.spy()
            emitter.onNext(hash)

        it "calls the listeners when the events are published", ->
            publisher.publish("event1")
            publisher.publish("event2")

            sinon.assert.calledOnce(hash.event1)
            sinon.assert.calledOnce(hash.event2)
            sinon.assert.notCalled(hash.event3)

        it "does not call the listeners when the events are published twice", ->
            publisher.publish("event1")
            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event2")

            sinon.assert.calledOnce(hash.event1)
            sinon.assert.calledOnce(hash.event2)
            sinon.assert.notCalled(hash.event3)

        it "does not call the listeners when they are mass-unsubscribed using the same hash", ->
            emitter.off(hash)

            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event3")

            sinon.assert.notCalled(hash.event1)
            sinon.assert.notCalled(hash.event2)
            sinon.assert.notCalled(hash.event3)
