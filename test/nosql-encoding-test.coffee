chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
EncodingNoSQL   = require '../src/nosql-encoding'
Errors          = require 'abstract-object/Error'
util            = require 'abstract-object/util'
inherits        = util.inherits
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "EncodingNoSQL", ->
    #before (done)->
    #after (done)->

