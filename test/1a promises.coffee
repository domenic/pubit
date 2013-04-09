Publisher = require("../lib/pubit-as-promised").Publisher
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

    xdescribe "when an event has been subscribed to that returns a promise", ->
        listener = null
        unsubscribe = null

        beforeEach ->
            listener = sinon.spy(-> return Q.timeout(100))
            unsubscribe = emitter.on("eventName", listener)

        it "publish should return the a promise fulfiled in ~100 msecs", (done) ->
            this.timeout(200)
            publisher.publish("eventName").done(done)

    xdescribe "when an event has been subscribed to that throws an exception", ->
        unsubscribe = null
        errorThrowingListener = null

        beforeEach ->
            errorThrowingListener = sinon.spy(-> throw new Error("ouch!"))
            unsubscribe = emitter.on("eventName", errorThrowingListener)

        it "publish should return a promise", ->
            promise = publisher.publish("eventName")

            Q.isPromise(promise).should.equal(true)
            promise.catch(->)

    describe "when an event has NOT been subscribed to", ->

        it "publish should return a promise", ->
            promise = publisher.publish("eventName")

            Q.isPromise(promise).should.equal(true)




