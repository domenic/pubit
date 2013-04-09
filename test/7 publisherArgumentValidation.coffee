Publisher = require("../lib/pubit-as-promised").Publisher

describe "Publisher argument validation", ->
    publisher = null

    beforeEach ->
        publisher = new Publisher()

    describe ".publish(eventName)", ->
        it "throws an error when given a number", ->
            (-> publisher.publish(5)).should.throwArgumentError("eventName", "string")
        
        it "throws an error when given null", ->
            (-> publisher.publish(null)).should.throwArgumentError("eventName", "string")

        it "throws an error when given an object", ->
            (-> publisher.publish({})).should.throwArgumentError("eventName", "string")
