"use strict";

var chai = require("chai");
var argumentErrorChaiPlugin = require("./argumentErrorChaiPlugin");

chai.use(argumentErrorChaiPlugin);
chai.should();

global.sinon = require("sinon");
