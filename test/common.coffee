chai = require("chai")
chai.should()

sinon = require("sinon")
sinonChai = require("sinon-chai")
chai.use sinonChai

global.sinon = sinon
