expect = require("chai").expect
require("./helpers")()

Publisher = require("../lib/pubit").Publisher

describe "Emitter argument validation", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe ".on(eventName, listener)", ->
        it "throws an error when give a string and a number", ->
            expect(-> emitter.on("eventName", 5)).to.throwArgumentError("listener", "function")

        it "throws an error when give a string and null", ->
            expect(-> emitter.on("eventName", null)).to.throwArgumentError("listener", "function")

        it "throws an error when give null and a function", ->
            expect(-> emitter.on(null, ->)).to.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            expect(-> emitter.on(5, ->)).to.throwArgumentError("eventName", "string")

    describe ".on(eventHash)", ->
        it "throws an error when given a number", ->
            expect(-> emitter.on(5)).to.throwArgumentError("hash", "string-to-function hash")
        
        it "throws an error when given null", ->
            expect(-> emitter.on(null)).to.throwArgumentError("hash", "string-to-function hash")

        it "throws an error when given a string by itself", ->
            expect(-> emitter.on("eventName")).to.throwArgumentError("hash", "string-to-function hash")

    describe ".off(eventName, listener)", ->
        it "throws an error when give a string and a number", ->
            expect(-> emitter.off("eventName", 5)).to.throwArgumentError("listener", "function")

        it "throws an error when give a string and null", ->
            expect(-> emitter.off("eventName", null)).to.throwArgumentError("listener", "function")

        it "throws an error when give null and a function", ->
            expect(-> emitter.off(null, ->)).to.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            expect(-> emitter.off(5, ->)).to.throwArgumentError("eventName", "string")

    describe ".off(eventHash)", ->
        it "throws an error when given a number", ->
            expect(-> emitter.off(5)).to.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
        
        it "throws an error when given null", ->
            expect(-> emitter.off(null)).to.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
