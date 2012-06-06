"use strict";

var chai = require("chai");
var sinonChai = require("sinon-chai");
var argumentErrorChaiPlugin = require("./argumentErrorChaiPlugin");

chai.use(argumentErrorChaiPlugin);
chai.use(sinonChai);
chai.should();

global.sinon = require("sinon");
