# Anon ![travis](https://travis-ci.org/kevinresol/anon.svg?branch=master)

Runtime type check and value extractor for dynamic objects

## Background

Sometimes we just cannot make sure the data type during compile time,
usually when the input data comes from external source. For example:

```haxe
var obj:{myInt:Int} = Json.parse('{"myString":"hello, world"}');
trace(obj.myInt + 10); // fail

// for the best security, we need to check it manually
if(obj.myInt == null || !Std.is(obj.myInt, Int)) throw "Invalid data";
```

However, thanks to Haxe macros, we don't need to write these check codes manually.
This library helps you generate the validation codes and also make sure the resulting
object contains only the fields you need.

## Usage

```haxe
var source:Dynamic = {a:1, b:"2"};
var r:{a:Int} = Anon.extract(source); // r is {a:1}

var source:Dynamic = {a:1, b:"2"};
var r:{a:Int, ?c:Int} = Anon.extract(source); // r is {a:1, c:null}

var source:Dynamic = {a:1, b:"2"};
var r:{a:Int, c:Int} = Anon.extract(source); // error: the field `c` does not exist
```