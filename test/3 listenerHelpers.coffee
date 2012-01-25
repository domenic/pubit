require("chai").should()
sinon = require("sinon")

pubit = require("../lib/pubit")

describe "Listener-creating helpers", ->
    publisher = null
    emitter = null
    clock = null

    beforeEach ->
        publisher = new pubit.Publisher()
        emitter = publisher.emitter
        clock = sinon.useFakeTimers()
    afterEach ->
        clock.restore()

    describe "throttledListener", ->
        it "should be called in a throttled manner", ->
            aggregateListener = sinon.spy()
            throttledListener = pubit.throttledListener(aggregateListener, 100)

            throttledListener()
            throttledListener()
            throttledListener()

            # Three calls to the throttled listener result in zero calls to the aggregate listener after 99 ms.
            clock.tick(99)
            sinon.assert.notCalled(aggregateListener)

            # But they do get aggrebated into one call to the aggregate listener after 101 ms.
            clock.tick(2)
            sinon.assert.calledOnce(aggregateListener)

            # If there are no further calls in the interim, nothing should happen by the 201 ms mark.
            clock.tick(100)
            sinon.assert.calledOnce(aggregateListener)

            # Then, a call at the 201 ms mark should not immediately result in a second call to the aggregate listener.
            throttledListener()
            sinon.assert.calledOnce(aggregateListener)

            # Even after 50 ms have gone by (251 ms mark).
            clock.tick(50)
            throttledListener()
            sinon.assert.calledOnce(aggregateListener)

            # By the 301 ms mark, the previous calls to the throttled listener result in a second call to the aggregate listener.
            clock.tick(50)
            sinon.assert.calledTwice(aggregateListener)

            # By the 401 ms mark, no further calls to the aggregate listener have been made.
            clock.tick(100)
            sinon.assert.calledTwice(aggregateListener)

        it "should aggregate the arguments of calls made to the throttled listener", ->
            aggregateListener = sinon.spy()
            throttledListener = pubit.throttledListener(aggregateListener, 100)

            throttledListener(1)
            clock.tick(20)
            throttledListener(2)
            clock.tick(20)
            throttledListener(3)
            clock.tick(61)

            sinon.assert.calledWithExactly(aggregateListener, [1, 2, 3])

            throttledListener("A")
            clock.tick(100)

            sinon.assert.calledWithExactly(aggregateListener, ["A"])
