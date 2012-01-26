require("chai").should()
sinon = require("sinon")

pubit = require("../lib/pubit")

describe "Listener-creating helpers", ->
    publisher = null
    emitter = null
    clock = null
    aggregateListener = null

    beforeEach ->
        publisher = new pubit.Publisher()
        emitter = publisher.emitter
        clock = sinon.useFakeTimers()
        aggregateListener = sinon.spy()
    afterEach ->
        clock.restore()

    describe "throttledListener", ->
        throttledListener = null

        beforeEach ->
            throttledListener = pubit.throttledListener(aggregateListener, 100)

        it "should be called in a throttled manner", ->
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

        describe "with the asap parameter set to true", ->
            beforeEach ->
                throttledListener = pubit.throttledListener(aggregateListener, 100, true)

            it "should call the aggregate listener on the next turn with the first value", (next) ->
                throttledListener(1)
                
                # Should not be called synchronously, for consistency: throttledListener always returns a function that
                # executes in a future turn of the event loop. It also allows us to aggregate all values that happen in
                # this initial turn, as shown in the next test.
                sinon.assert.notCalled(aggregateListener)

                # After a turn of the event loop, it's been called.
                process.nextTick ->
                    sinon.assert.calledWithExactly(aggregateListener, [1])
                    next()

            it "should call the aggregate listener once with all initial values, then later as usual", (next) ->
                throttledListener(1)
                throttledListener(2)
                throttledListener(3)

                sinon.assert.notCalled(aggregateListener)

                process.nextTick ->
                    sinon.assert.calledWithExactly(aggregateListener, [1, 2, 3])

                    throttledListener("A")
                    clock.tick(20)
                    throttledListener("B")
                    clock.tick(20)
                    throttledListener("C")
                    clock.tick(61)
                    sinon.assert.calledWithExactly(aggregateListener, ["A", "B", "C"])

                    next()

    describe "debouncedListener", ->
        debouncedListener = null

        beforeEach ->
            debouncedListener = pubit.debouncedListener(aggregateListener, 100)

        it "should be called in a debounced manner", ->
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

        describe "with the asap parameter set to true", ->
            beforeEach ->
                debouncedListener = pubit.debouncedListener(aggregateListener, 100, true)

            it "should call the aggregate listener on the next turn with the first value", (next) ->
                debouncedListener(1)
                
                # Should not be called synchronously, for consistency: debouncedListener always returns a function that
                # executes in a future turn of the event loop. It also allows us to aggregate all values that happen in
                # this initial turn, as shown in the next test.
                sinon.assert.notCalled(aggregateListener)

                # After a turn of the event loop, it's been called.
                process.nextTick ->
                    sinon.assert.calledWithExactly(aggregateListener, [1])
                    next()

            it "should call the aggregate listener once with all initial values, then later as usual", (next) ->
                debouncedListener(1)
                debouncedListener(2)
                debouncedListener(3)

                sinon.assert.notCalled(aggregateListener)

                process.nextTick ->
                    sinon.assert.calledWithExactly(aggregateListener, [1, 2, 3])

                    debouncedListener("A")
                    clock.tick(20)
                    debouncedListener("B")
                    clock.tick(20)
                    debouncedListener("C")
                    clock.tick(101)
                    sinon.assert.calledWithExactly(aggregateListener, ["A", "B", "C"])

                    next()
