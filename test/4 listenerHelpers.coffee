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

            # But they do get aggregated into one call to the aggregate listener after 101 ms.
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

            # But by the 301 ms mark, the previous calls result in a second call to the aggregate listener.
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
            clock.tick(101)

            sinon.assert.calledWithExactly(aggregateListener, ["A"])

    describe "debouncedListener", ->
        it "should be called in a debounced manner", ->
            aggregateListener = sinon.spy()
            debouncedListener = pubit.debouncedListener(aggregateListener, 100)

            debouncedListener()
            debouncedListener()
            debouncedListener()

            # Three calls to the debounced listener result in zero calls to the aggregate listener after 99 ms.
            clock.tick(99)
            sinon.assert.notCalled(aggregateListener)

            # But they do get aggregated into one call to the aggregate listener after 101 ms.
            clock.tick(2)
            sinon.assert.calledOnce(aggregateListener)

            # If there are no further calls in the interim, nothing should happen by the 201 ms mark.
            clock.tick(100)
            sinon.assert.calledOnce(aggregateListener)

            # Then, calling at 50-ms intervals (251 ms, 301 ms, 351 ms, 401 ms) should not result in any calls.
            # (This is the main difference between throttling and debouncing.)
            debouncedListener()
            clock.tick(50)
            sinon.assert.calledOnce(aggregateListener)

            debouncedListener()
            clock.tick(50)
            sinon.assert.calledOnce(aggregateListener)

            debouncedListener()
            clock.tick(50)
            sinon.assert.calledOnce(aggregateListener)

            debouncedListener()
            clock.tick(50)
            sinon.assert.calledOnce(aggregateListener)

            # But, if we wait another 50 ms (451 ms mark), then the aggregate listener gets called.
            clock.tick(50)
            sinon.assert.calledTwice(aggregateListener)

        it "should aggregate the arguments of calls made to the debounced listener", ->
            aggregateListener = sinon.spy()
            debouncedListener = pubit.debouncedListener(aggregateListener, 100)

            debouncedListener(1)
            clock.tick(99)
            debouncedListener(2)
            clock.tick(99)
            debouncedListener(3)
            clock.tick(101)
            
            sinon.assert.calledWithExactly(aggregateListener, [1, 2, 3])

            debouncedListener("A")
            clock.tick(101)

            sinon.assert.calledWithExactly(aggregateListener, ["A"])
