Assertion = require("chai").Assertion

module.exports = ->
    # Add a throwArgumentError(argName, type) matcher.
    Assertion.prototype.throwArgumentError = (argName, type) ->
        (new Assertion(@obj)).is.a("function")

        try
            @obj()
        catch error
            @assert(
                error instanceof TypeError and error.message is "#{ argName } argument must be a #{ type }.",
                "expected #{ @inspect } to throw an argument error requiring #{ argName } to be of type #{ type }"
            )

        return this
