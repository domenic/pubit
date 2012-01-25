expect = require("chai").expect
require("./helpers")()

Publisher = require("../lib/pubit").Publisher

describe "Publisher argument validation", ->
    publisher = null

    beforeEach ->
        publisher = new Publisher()

    describe ".publish(eventName)", ->
        it "throws an error when given a number", ->
            expect(-> publisher.publish(5)).to.throwArgumentError("eventName", "string")
        
        it "throws an error when given null", ->
            expect(-> publisher.publish(null)).to.throwArgumentError("eventName", "string")

        it "throws an error when given an object", ->
            expect(-> publisher.publish("eventName")).to.throwArgumentError("eventName", "string")
