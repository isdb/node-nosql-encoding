# Nosql Encoding Ability.

[![Build Status](https://secure.travis-ci.org/snowyu/node-nosql-encoding.png?branch=master)](http://travis-ci.org/snowyu/node-nosql-encoding)

[![NPM](https://nodei.co/npm/nosql-encoding.png?stars&downloads&downloadRank)](https://nodei.co/npm/nosql-encoding/)

Add the encoding ability to the [abstract-nosql](https://github.com/snowyu/node-abstract-nosql) database.



# Usage

## Add the Encoding ability to a nosql database

    npm install nosql-encoding
    npm install encoding-iterator

```js

var Encoding = require("nosql-encoding")
var LevelDB  = Encoding(require("leveldown-sync"))

var db = LevelDB('location')
db.open({keyEncoding: 'text', valueEncoding: 'json'})

```

## Develop a nosql database with encoding ability


Coffee-Script:

```coffee

inherits      = require('abstract-object/util').inherits
EncodingNoSQL = require('nosql-encoding')

class MyDatabase
    inherits MyDatabase, EncodingNoSQL

```


# Encoding Codec

See [buffer-codec](https://github.com/snowyu/node-buffer-codec).

## Codec List:

* Text Codec: encode via toString() , decode return the data directly.
  * Json Codec: encode via JSON.stringify(.toJSON), decode via JSON.parse
  * Hex Codec: hex string to Binary.
* Binary Codec:
  * encodeBuffer: encode string or array to a buffer.
  * decodeBuffer: return the buffer directly.
  * encodeString: 
    * result is the same string if value is string
    * result is ascii string if value is array, the number element in array saved is (element & 0xFF)
      if element is not number, saved 0 instead.
  * decodeString: return the same string.



