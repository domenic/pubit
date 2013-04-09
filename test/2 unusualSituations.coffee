Publisher = require("../lib/pubit-as-promised").Publisher

describe "Publisher/emitter in unusual situations", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe "when an event has been subscribed to by two normal listeners plus a listener that removes itself", ->
        normalListener1 = null
        normalListener2 = null
        selfRemovingListener = null

        beforeEach ->
            normalListener1 = sinon.spy()
            normalListener2 = sinon.spy()
            selfRemovingListener = sinon.spy(-> emitter.off("eventName", selfRemovingListener))

            emitter.on("eventName", normalListener1)
            emitter.on("eventName", selfRemovingListener)
            emitter.on("eventName", normalListener2)

        it "should call all listeners when the event is published once", ->
            publisher.publish("eventName")

            normalListener1.should.have.been.calledOnce
            normalListener2.should.have.been.calledOnce
            selfRemovingListener.should.have.been.calledOnce

        it "should only call the normal listeners when the event is published a second time", ->
            publisher.publish("eventName")
            publisher.publish("eventName")

            normalListener1.should.have.been.calledTwice
            normalListener2.should.have.been.calledTwice
            selfRemovingListener.should.have.been.calledOnce

    describe "when an event has been subscribed to by two normal listeners plus a listener that throws an error", ->
        normalListener1 = null
        normalListener2 = null
        errorThrowingListener = null

        beforeEach ->
            publisher = new Publisher(onListenerError: ->)
            emitter = publisher.emitter

            normalListener1 = sinon.spy()
            normalListener2 = sinon.spy()
            errorThrowingListener = sinon.spy(-> throw new Error)

            emitter.on("eventName", normalListener1)
            emitter.on("eventName", errorThrowingListener)
            emitter.on("eventName", normalListener2)

        it "should call all listeners when the event is published, despite the error", ->
            publisher.publish("eventName").catch(->)

            normalListener1.should.have.been.calledOnce
            normalListener2.should.have.been.calledOnce
            errorThrowingListener.should.have.been.calledOnce

    it 'gracefully deals with events named "hasOwnProperty"', ->
        listener = sinon.spy()

        emitter.on("hasOwnProperty", listener)
        publisher.publish("hasOwnProperty")

        listener.should.have.been.calledOnce

    it 'gracefully deals with events named "__proto__"', ->
        listener = sinon.spy()

        emitter.on("__proto__", listener)
        publisher.publish("__proto__")

        listener.should.have.been.calledOnce
