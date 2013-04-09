Publisher = require("..").Publisher

describe "Publisher/emitter under normal usage", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when an event has been subscribed to", ->
        listener = null
        unsubscribe = null

        beforeEach ->
            listener = sinon.spy()
            unsubscribe = emitter.on("eventName", listener)

        it "should call the subscribing listener when the event is published", ->
            publisher.publish("eventName")

            listener.should.have.been.calledOnce

        it "should call the listener with the supplied arguments when the event is published with arguments", ->
            publisher.publish("eventName", 1, "foo")
            
            listener.should.have.been.calledWithExactly(1, "foo")

        it "should not call the listener when publishing a different event", ->
            publisher.publish("anotherEvent")

            listener.should.not.have.been.called

        it "should not call the listener when publishing after unsubscribing from the event", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            listener.should.not.have.been.called

        it "should not call the listener when publishing after unsubscribing with the function 'on' returns", ->
            unsubscribe()
            publisher.publish("eventName")

            listener.should.not.have.been.called

    describe "when an event has been subscribed to twice by the same listener", ->
        listener = null

        beforeEach ->
            listener = sinon.spy()
            emitter.on("eventName", listener)
            emitter.on("eventName", listener)

        it "should call the subscribing listener twice when the event is published", ->
            publisher.publish("eventName")

            listener.should.have.been.calledTwice

        it "should call the subscribing listener once when the event is unsubscribed from once, then published", ->
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            listener.should.have.been.calledOnce

        it "should not call the subscribing listener when the event is unsubscribed from twice, then published", ->
            emitter.off("eventName", listener)
            emitter.off("eventName", listener)
            publisher.publish("eventName")

            listener.should.not.have.been.called

        it "should not call the subscribing listener when the event is blanket-unsubscribed, then published", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            listener.should.not.have.been.called

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

            listener1.should.have.been.calledOnce
            listener2.should.have.been.calledOnce
        
        it "should call only one listener when the other unsubscribes, then the event is published", ->
            emitter.off("eventName", listener1)
            publisher.publish("eventName")

            listener1.should.not.have.been.called
            listener2.should.have.been.calledOnce

        it "should call neither listener when the event is blanket-unsubscribed, then published", ->
            emitter.off("eventName")
            publisher.publish("eventName")

            listener1.should.not.have.been.called
            listener2.should.not.have.been.called

    describe "when three events are subscribed to in one call", ->
        events = ["event1", "event2", "event3"]
        listener = null
        unsubscribe = null

        beforeEach ->
            listener = sinon.spy()
            unsubscribe = emitter.on(events.join(" "), listener)

        it "publishes the first event correctly", ->
            publisher.publish("event1")

            listener.should.have.been.calledOnce

        it "publishes the second event correctly", ->
            publisher.publish("event2")

            listener.should.have.been.calledOnce

        it "publishes the third event correctly", ->
            publisher.publish("event3")

            listener.should.have.been.calledOnce

        it "unsubscribes from two events at once correctly, when passed the listener explicitly", ->
            emitter.off("event2 event3", listener)
            publisher.publish("event2")
            publisher.publish("event3")

            listener.should.not.have.been.called

        it "unsubscribes from two events at once correctly, when doing blanket unsubscription", ->
            emitter.off("event2 event3")
            publisher.publish("event2")
            publisher.publish("event3")

            listener.should.not.have.been.called

        it "unsubscribes from two events at once, when calling the returned unsubscriber", ->
            unsubscribe()
            publisher.publish("event2")
            publisher.publish("event3")

            listener.should.not.have.been.called

    describe "when a hash object mapping event names to listeners is used for subscription", ->
        hash = null
        unsubscribe = null

        beforeEach ->
            hash = 
                event1: sinon.spy()
                event2: sinon.spy()
                event3: sinon.spy()
            unsubscribe = emitter.on(hash)

        it "publishes events correctly", ->
            publisher.publish("event1")
            publisher.publish("event2")

            hash.event1.should.have.been.calledOnce
            hash.event2.should.have.been.calledOnce
            hash.event3.should.not.have.been.called

        it "does not publish events when they are mass-unsubscribed using the same hash", ->
            emitter.off(hash)

            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event3")

            hash.event1.should.not.have.been.called
            hash.event2.should.not.have.been.called
            hash.event3.should.not.have.been.called

        it "does not publish events when they are unsubscribed with the returned function", ->
            unsubscribe()

            publisher.publish("event1")
            publisher.publish("event2")
            publisher.publish("event3")

            hash.event1.should.not.have.been.called
            hash.event2.should.not.have.been.called
            hash.event3.should.not.have.been.called

