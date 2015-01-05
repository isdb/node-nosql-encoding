chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
EncodingNoSQL   = require '../src/nosql-encoding'
Errors          = require 'abstract-object/Error'
util            = require 'abstract-object/util'
Codec           = require 'buffer-codec'
EncodingIterator= require("encoding-iterator")
inherits        = util.inherits
setImmediate    = setImmediate || process.nextTick

chai.use(sinonChai)

describe "EncodingNoSQL", ->
  class FakeIterator
    inherits FakeIterator, EncodingIterator
    constructor: ()->
      @i=0
      super
    _nextSync: ->[JSON.stringify(["key"+@i]), JSON.stringify([@i++])]
  class FakeDB
    inherits FakeDB, EncodingNoSQL
    constructor: ->super
    _openSync: ->true
    _closeSync:->true
    _isExistsSync: sinon.spy (key)->true
    _getBufferSync: sinon.spy ->
    _getSync: sinon.spy (key)->key
    _putSync: sinon.spy (key,value)->true
    _delSync: sinon.spy (key)->true
    _batchSync: sinon.spy ->true
    IteratorClass: FakeIterator
  before ->
    @db = new FakeDB()
  after ->
    @db.close()

  describe ".open", ->
    it "should set string encoding when open", ->
      @db.open({keyEncoding:'json', valueEncoding: 'text'})
      @db._options.keyEncoding.should.be.equal Codec('json')
      @db._options.valueEncoding.should.be.equal Codec('text')
    it "should set encoding instance when open", ->
      json = new Codec['json']
      @db.open({keyEncoding:json})
      @db._options.keyEncoding.should.be.equal json
      should.not.exist @db._options.valueEncoding
    it "should set undefined encoding when open unknown encoding", ->
      @db.open({keyEncoding:'Not FOund', valueEncoding: 'No SUch'})
      should.not.exist @db._options.keyEncoding
      should.not.exist @db._options.valueEncoding

  describe ".isExistsSync", ->
    it "should encode key", ->
      @db.open({keyEncoding:'json'})
      expectedKey = {myKeyName: 12345}
      @db.isExistsSync expectedKey
      @db._isExistsSync.should.have.been.calledWith JSON.stringify expectedKey
  describe ".isExists", ->
    it "should encode key sync", ->
      @db.open({keyEncoding:'json'})
      expectedKey = {myKeyName: 12345}
      @db.isExists expectedKey
      @db._isExistsSync.should.have.been.calledWith JSON.stringify expectedKey
    it "should encode key async", (done)->
      @db.open({keyEncoding:'json'})
      expectedKey = {myKeyName: 12}
      @db.isExists expectedKey, (err, result)=>
        should.not.exist err
        @db._isExistsSync.should.have.been.calledWith JSON.stringify expectedKey
        done()

  describe ".getBuffer directly", ->
    describe ".getBufferSync", ->
      it "should encode key", ->
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBufferSync expectedKey
        @db._getBufferSync.should.have.been.calledWith JSON.stringify expectedKey
    describe ".getBuffer", ->
      it "should encode key sync", ->
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBuffer expectedKey
        @db._getBufferSync.should.have.been.calledWith JSON.stringify expectedKey
      it "should encode key async", (done)->
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBuffer expectedKey, null, (err, result)=>
          should.not.exist err
          @db._getBufferSync.should.have.been.calledWith JSON.stringify expectedKey
          done()
  describe ".getBuffer with _get", ->
    old_getBufferSync = FakeDB::_getBufferSync
    beforeEach: ->
    after: ->
      FakeDB::_getBufferSync = old_getBufferSync
    describe ".getBufferSync", ->
      it "should encode key", ->
        delete FakeDB::_getBufferSync
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBufferSync expectedKey
        @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
    describe ".getBuffer", ->
      it "should encode key sync", ->
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBuffer expectedKey
        @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
      it "should encode key async", (done)->
        @db.open({keyEncoding:'json'})
        expectedKey = myKeyName: Math.random()
        @db.getBuffer expectedKey, null, (err, result)=>
          should.not.exist err
          @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
          done()

  describe ".mGetSync", ->
    it "should encode key, decode value", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      result = @db.mGetSync expectedKey
      for o, i in result
        o.key.should.be.deep.equal expectedKey[i]
        o.value.should.be.deep.equal expectedKey[i]
    it "should encode key only", ->
      @db.open({keyEncoding:'json'})
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      result = @db.mGetSync expectedKey
      for o, i in result
        o.key.should.be.deep.equal expectedKey[i]
        o.value.should.be.deep.equal JSON.stringify expectedKey[i]
  describe ".mGet", ->
    it "should encode key sync", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      result = @db.mGet expectedKey
      for o, i in result
        o.key.should.be.deep.equal expectedKey[i]
        o.value.should.be.deep.equal expectedKey[i]
    it "should encode key only sync", ->
      @db.open({keyEncoding:'json'})
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      result = @db.mGet expectedKey
      for o, i in result
        o.key.should.be.deep.equal expectedKey[i]
        o.value.should.be.deep.equal JSON.stringify expectedKey[i]
    it "should encode key, decode value async", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      @db.mGet expectedKey, (err, result)=>
        should.not.exist err
        for o, i in result
          o.key.should.be.deep.equal expectedKey[i]
          o.value.should.be.deep.equal expectedKey[i]
        done()
    it "should encode key only async", (done)->
      @db.open keyEncoding:'json'
      i = 0
      expectedKey = while i++ < 10
        myKeyName: Math.random()
      @db.mGet expectedKey, (err, result)=>
        should.not.exist err
        for o, i in result
          o.key.should.be.deep.equal expectedKey[i]
          o.value.should.be.deep.equal JSON.stringify expectedKey[i]
        done()

  describe ".getSync", ->
    it "should encode key", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.getSync expectedKey
      @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
  describe ".get", ->
    it "should encode key sync", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.get expectedKey
      @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
    it "should encode key async", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.get expectedKey, (err, result)=>
        should.not.exist err
        @db._getSync.should.have.been.calledWith JSON.stringify expectedKey
        done()

  describe ".putSync", ->
    it "should encode key,value", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey   = myKeyName: Math.random()
      expectedValue = myValueName: Math.random()
      @db.putSync expectedKey, expectedValue
      @db._putSync.should.have.been.calledWith JSON.stringify(expectedKey), JSON.stringify(expectedValue)
  describe ".put", ->
    it "should encode key,value sync", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      expectedValue = myValueName: Math.random()
      @db.putSync expectedKey, expectedValue
      @db._putSync.should.have.been.calledWith JSON.stringify(expectedKey), JSON.stringify(expectedValue)
    it "should encode key,value async", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      expectedValue = myValueName: Math.random()
      @db.put expectedKey, expectedValue, (err, result)=>
        should.not.exist err
        @db._putSync.should.have.been.calledWith JSON.stringify(expectedKey), JSON.stringify(expectedValue)
        done()

  describe ".delSync", ->
    it "should encode key", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.delSync expectedKey
      @db._delSync.should.have.been.calledWith JSON.stringify expectedKey
  describe ".del", ->
    it "should encode key sync", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.del expectedKey
      @db._delSync.should.have.been.calledWith JSON.stringify expectedKey
    it "should encode key async", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      expectedKey = myKeyName: Math.random()
      @db.del expectedKey, (err, result)=>
        should.not.exist err
        @db._delSync.should.have.been.calledWith JSON.stringify expectedKey
        done()


  describe ".batchSync", ->
    it "should encode key", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      ops = [
          type: "put"
          key: [Math.random()]
          value: v:Math.random()
        ,
          type: "del"
          key: [Math.random()]
      ]
      expectedOps = ops.slice()
      expectedOps.map (i)->
        i.key = JSON.stringify i.key
        i.value = JSON.stringify i.value if i.value
      @db.batchSync ops
      @db._batchSync.should.have.been.calledWith expectedOps
  describe ".batch", ->
    it "should encode key sync", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      ops = [
          type: "put"
          key: [Math.random()]
          value: v:Math.random()
        ,
          type: "del"
          key: [Math.random()]
      ]
      expectedOps = ops.slice()
      expectedOps.map (i)->
        i.key = JSON.stringify i.key
        i.value = JSON.stringify i.value if i.value
      @db.batch ops
      @db._batchSync.should.have.been.calledWith expectedOps
    it "should encode key async", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      ops = [
          type: "put"
          key: [Math.random()]
          value: v:Math.random()
        ,
          type: "del"
          key: [Math.random()]
      ]
      expectedOps = ops.slice()
      expectedOps.map (i)->
        i.key = JSON.stringify i.key
        i.value = JSON.stringify i.value if i.value
      @db.batch ops, (err, result)=>
        should.not.exist err
        @db._batchSync.should.have.been.calledWith expectedOps
        done()

  describe ".iterator", ->
    it "should encode range", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      iterator = @db.iterator lt:{key:123}
      iterator.options.should.have.property "lt", JSON.stringify {key:123}
    it "should encode range keys", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      keys = [{ikey:Math.random()}, {ikey:Math.random()}]
      expectedKeys = keys.map JSON.stringify
      iterator = @db.iterator range: keys
      iterator.options.range.should.be.deep.equal expectedKeys
    it "should decode nextSync result", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      iterator = @db.iterator()
      i = -1
      while i++ < 10
        result = iterator.nextSync()
        result.should.be.deep.equal key:["key"+i], value:[i]
    it "should decode next result", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      iterator = @db.iterator()
      i = 0
      nextOne = ->
        iterator.next (err, key, value)->
          should.not.exist err
          key.should.be.deep.equal ["key"+i]
          value.should.be.deep.equal [i]
          if ++i < 10
            nextOne()
          else
            done()
      nextOne()
    it "should decode nextSync range keys result", ->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      keys = [1..10].map -> ikey:Math.random()
      expectedKeys = keys.map (v)->
        key: v
        value: v
      iterator = @db.iterator range:keys
      i = 0
      result = []
      while i < keys.length
        result.push iterator.nextSync()
        i++

      result.should.be.deep.equal expectedKeys
    it "should decode next range keys result", (done)->
      @db.open({keyEncoding:'json', valueEncoding: 'json'})
      keys = [1..10].map -> ikey:Math.random()
      expectedKeys = keys.map (v)->
        key:  v
        value: v
      iterator = @db.iterator range:keys
      result=[]
      nextOne= ->
        iterator.next (err, key, value)->
          should.not.exist err
          result.push
            key:key
            value:value
          if result.length < keys.length
            nextOne()
          else
            result.should.be.deep.equal expectedKeys
            done()
      nextOne()

