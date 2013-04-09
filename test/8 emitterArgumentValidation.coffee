Publisher = require("../lib/pubit-as-promised").Publisher

describe "Emitter argument validation", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe ".on(eventName, listener)", ->
        it "throws an error when give a string and a number", ->
            (-> emitter.on("eventName", 5)).should.throwArgumentError("listener", "function")

        it "throws an error when give a string and null", ->
            (-> emitter.on("eventName", null)).should.throwArgumentError("listener", "function")

        it "throws an error when give null and a function", ->
            (-> emitter.on(null, ->)).should.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            (-> emitter.on(5, ->)).should.throwArgumentError("eventName", "string")

    describe ".on(eventHash)", ->
        it "throws an error when given a number", ->
            (-> emitter.on(5)).should.throwArgumentError("hash", "string-to-function hash")
        
        it "throws an error when given null", ->
            (-> emitter.on(null)).should.throwArgumentError("hash", "string-to-function hash")

        it "throws an error when given a string by itself", ->
            (-> emitter.on("eventName")).should.throwArgumentError("hash", "string-to-function hash")

    describe ".off(eventName, listener)", ->
        it "throws an error when give a string and a number", ->
            (-> emitter.off("eventName", 5)).should.throwArgumentError("listener", "function")

        it "throws an error when give a string and null", ->
            (-> emitter.off("eventName", null)).should.throwArgumentError("listener", "function")

        it "throws an error when give null and a function", ->
            (-> emitter.off(null, ->)).should.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            (-> emitter.off(5, ->)).should.throwArgumentError("eventName", "string")

    describe ".off(eventHash)", ->
        it "throws an error when given a number", ->
            (-> emitter.off(5)).should.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
        
        it "throws an error when given null", ->
            (-> emitter.off(null)).should.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
