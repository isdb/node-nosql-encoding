# Copyright (c) 2014 Riceball LEE, MIT License
#xtend                 = require("xtend")
util                  = require("abstract-object/lib/util")
AbstractNoSQL         = require("abstract-nosql")
#try AbstractIterator  = require("abstract-iterator")
inherits              = util.inherits
isInheritedFrom       = util.isInheritedFrom
inheritsDirectly      = util.inheritsDirectly


module.exports = class EncodingNoSQL
  inherits EncodingNoSQL, AbstractNoSQL

  constructor: (aClass)->
    if (this not instanceof EncodingNoSQL)
      aParentClass = isInheritedFrom aClass, AbstractNoSQL
      if aParentClass
        inheritsDirectly aParentClass, EncodingNoSQL if aParentClass isnt EncodingNoSQL
        return aClass
    super
  #mergeOptions: (options, opts1, opts2)->xtend(@_options, options, opts1, opts2)
  keyEncoding: (options)->
    if options and options.KeyEncoding
      encoding = options.KeyEncoding
      encoding = Codec(encoding) if encoding
    else
      encoding = @_options.keyEncoding
    encoding
  valueEncoding: (options)->
    if options and options.valueEncoding
      encoding = options.valueEncoding
      encoding = Codec(encoding) if encoding
    else
      encoding = @_options.valueEncoding
    encoding
  setOpened: (isOpened, options)->
    super(isOpened, options)
    options = @_options
    if isOpened and options
      encoding = options.keyEncoding
      encoding = Codec(encoding) if encoding
      options.keyEncoding = encoding if encoding
      encoding = options.valueEncoding
      encoding = Codec(encoding) if encoding
      options.valueEncoding = encoding if encoding
    else if not options?
      @_options = {}
  isExistsSync: (key, options) ->
    keyEncoding = @keyEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    super(key, options)
  getSync: (key, options) ->
    encoding = @keyEncoding options
    key = encoding.encode(key) if keyEncoding
    result = super(key, options)
    encoding = @valueEncoding options
    result = encoding.decode(result) if encoding
    result
  getBufferSync: (key, destBuffer, options) ->
    encoding = @keyEncoding options
    key = encoding.encode(key) if keyEncoding
    super(key, destBuffer, options)
  mGetSync: (keys, options) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    keys = keys.map keyEncoding.encode if keyEncoding
    result = super(keys, options)
    if valueEncoding
      if (options.keys)
        result.map (item)->
          item.key = keyEncoding.decode item.key if keyEncoding
          item.value = valueEncoding.decode item.value if valueEncoding
      else
        result = result.map valueEncoding.encode
    result
  putSync: (key, value, options) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    value = valueEncoding.encode(value) if valueEncoding
    super(key, value, options)
  delSync: (key, options) ->
    keyEncoding = @keyEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    super(key, options)
  batchSync: (operations, options) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    for e in operations
      continue unless typeof e is "object"
      e.key = keyEncoding.encode(e.key) if keyEncoding
      e.value = valueEncoding.encode(e.value) if valueEncoding
    super(operations, options)
  #TODO: approximateSizeSync should not be here.
  approximateSizeSync:(start, end) ->
    keyEncoding = @keyEncoding options
    start = keyEncoding.encode(start) if keyEncoding and start isnt undefined
    end = keyEncoding.encode(end) if keyEncoding and end isnt undefined
    super(start, end)

  isExistsAsync: (key, options, callback) ->
    keyEncoding = @keyEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    super(key, options, callback)
  getAsync: (key, options, callback) ->
    encoding = @keyEncoding options
    key = encoding.encode(key) if keyEncoding
    encoding = @valueEncoding options
    super key, options, (err, value)->
      return callback(err) if err
      value = encoding.decode(value) if encoding
      callback null, value
  getBufferAsync: (key, destBuffer, options, callback) ->
    encoding = @keyEncoding options
    key = encoding.encode(key) if keyEncoding
    super(key, destBuffer, options, callback)
  mGetAsync: (keys, options, callback) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    keys = keys.map keyEncoding.encode if keyEncoding
    super keys, options, (err, result)->
      return callback(err) if err
      if valueEncoding
        if (options.keys)
          result.map (item)->
            item.key = keyEncoding.decode item.key if keyEncoding
            item.value = valueEncoding.decode item.value if valueEncoding
        else
          result = result.map valueEncoding.encode
      callback null, result
  putAsync: (key, value, options, callback) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    value = valueEncoding.encode(value) if valueEncoding
    super(key, value, options, callback)
  delAsync: (key, options, callback) ->
    keyEncoding = @keyEncoding options
    key = keyEncoding.encode(key) if keyEncoding
    super(key, options, callback)
  batchAsync: (operations, options, callback) ->
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    for e in operations
      continue unless typeof e is "object"
      e.key = keyEncoding.encode(e.key) if keyEncoding
      e.value = valueEncoding.encode(e.value) if valueEncoding
    super(operations, options, callback)
  #TODO: approximateSizeAsync should not be here.
  approximateSizeAsync:(start, end) ->
    keyEncoding = @keyEncoding options
    start = keyEncoding.encode(start) if keyEncoding and start isnt undefined
    end = keyEncoding.encode(end) if keyEncoding and end isnt undefined
    super(start, end)
  iterator: (options) ->
    options = {} unless options
    keyEncoding = @keyEncoding options
    valueEncoding = @valueEncoding options
    options.keyEncoding = keyEncoding if keyEncoding
    options.valueEncoding = valueEncoding if valueEncoding
    super(options)
