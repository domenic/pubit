Publisher = require("..").Publisher
Q = require("q")

describe "Promises", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when an event has been subscribed to 'old school'", ->
        listener = null
        unsubscribe = null

        beforeEach ->
            listener = sinon.spy()
            unsubscribe = emitter.on("eventName", listener)

        it "publish should return a promise", ->
            promise = publisher.publish("eventName")
            Q.isPromise(promise).should.equal(true)

    describe "when an event has NOT been subscribed to", ->

        it "publish should return a promise", ->
            promise = publisher.publish("eventName")

            Q.isPromise(promise).should.equal(true)
