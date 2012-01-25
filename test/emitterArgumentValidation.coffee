expect = require("chai").expect
require("./helpers")()

Publisher = require("../lib/pubit").Publisher

describe "Emitter argument validation", ->
    publisher = null
    emitter = null

    beforeEach ->
        publisher = new Publisher()
        emitter = publisher.emitter

    describe ".subscribe(eventName, handler)", ->
        it "throws an error when give a string and a number", ->
            expect(-> emitter.subscribe("eventName", 5)).to.throwArgumentError("handler", "function")

        it "throws an error when give a string and null", ->
            expect(-> emitter.subscribe("eventName", null)).to.throwArgumentError("handler", "function")

        it "throws an error when give null and a function", ->
            expect(-> emitter.subscribe(null, ->)).to.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            expect(-> emitter.subscribe(5, ->)).to.throwArgumentError("eventName", "string")

    describe ".subscribe(eventHash)", ->
        it "throws an error when given a number", ->
            expect(-> emitter.subscribe(5)).to.throwArgumentError("hash", "string-to-function hash")
        
        it "throws an error when given null", ->
            expect(-> emitter.subscribe(null)).to.throwArgumentError("hash", "string-to-function hash")

        it "throws an error when given a string by itself", ->
            expect(-> emitter.subscribe("eventName")).to.throwArgumentError("hash", "string-to-function hash")

    describe ".unsubscribe(eventName, handler)", ->
        it "throws an error when give a string and a number", ->
            expect(-> emitter.unsubscribe("eventName", 5)).to.throwArgumentError("handler", "function")

        it "throws an error when give a string and null", ->
            expect(-> emitter.unsubscribe("eventName", null)).to.throwArgumentError("handler", "function")

        it "throws an error when give null and a function", ->
            expect(-> emitter.unsubscribe(null, ->)).to.throwArgumentError("eventName", "string")

        it "throws an error when give a number and a function", ->
            expect(-> emitter.unsubscribe(5, ->)).to.throwArgumentError("eventName", "string")

    describe ".unsubscribe(eventHash)", ->
        it "throws an error when given a number", ->
            expect(-> emitter.unsubscribe(5)).to.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
        
        it "throws an error when given null", ->
            expect(-> emitter.unsubscribe(null)).to.throwArgumentError("eventNameOrHash", "string or string-to-function hash")
