# Nosql Encoding Ability.

[![Build Status](https://secure.travis-ci.org/snowyu/node-nosql-encoding.png?branch=master)](http://travis-ci.org/snowyu/node-nosql-encoding)

[![NPM](https://nodei.co/npm/nosql-encoding.png?stars&downloads&downloadRank)](https://nodei.co/npm/nosql-encoding/)

Add the encoding ability to the [abstract-nosql](https://github.com/snowyu/node-abstract-nosql) database.



# Usage

## Add the Encoding ability to a nosql database

    npm install nosql-encoding

```js

var addEncodingFeatureTo = require("nosql-encoding")
var LevelDB  = addEncodingFeatureTo(require("leveldown-sync"))

var db = LevelDB('location')
db.open({keyEncoding: 'text', valueEncoding: 'json'})

```

## Develop a nosql database with encoding ability

There is no need to force inherited from the Encoding class.

Please let the user decide whether to use the Encoding feature.


# Encoding Codec

See [buffer-codec](https://github.com/snowyu/node-buffer-codec).


