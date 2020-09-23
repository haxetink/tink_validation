# tink_validation 
[![Build Status](https://travis-ci.org/haxetink/tink_validation.svg?branch=master)](https://travis-ci.org/haxetink/tink_validation)
[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg?maxAge=2592000)](https://gitter.im/haxetink/public)

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

### Extractor

The extractor will get the data out of the passed object, checking type, setting to `null` the missing ones and returning the result.

```haxe
var source:Dynamic = {a:1, b:"2"};
var r:{a:Int} = Validation.extract(source); // r is {a:1}

var source:Dynamic = {a:1, b:"2"};
var r:{a:Int, ?c:Int} = Validation.extract(source); // r is {a:1, c:null}

var source: Dynamic = {a:"a", b: "2"};
var r:{a:Int, ?c:Int} = Validation.extract(source); // will throw UnexpectedType([a], Int, "a");
```

### Validator

The validator will only check the existence of fields and their type. If everything is alright, it won't return anything.

```haxe
var source:Dynamic = {a:1, b:"2"};
Validation.validate((source: {a:Int})); // OK

var source:Dynamic = {a:1, b:"2"};
Validation.validate((source: {a:Int, ?c:Int})); // OK

var source: Dynamic = {a:"a", b: "2"};
Validation.validate((source: {a:Int, c:Int})); // will throw MissingField([c]);

var source: Dynamic = {a:1, c: "2"};
Validation.validate((source: {a:Int, c:Int})); // will throw UnexpectedType([c], Int, "2");

var source: Dynamic = {a:1, c: {a:1, b:2}};
Validation.validate((source: {a:Int, c:{a:Int, b:String}})); // will throw UnexpectedType([c,b], String, 2);
```

### Errors

2 types errors can be thrown:
```
MissingField(path: Array<String>);
```
```
UnexpectedType(path: Array<String>, expectedType: Class, actualValue: Dynamic);
```

The first parameter `path` is an array of each object level passed by the validator before reaching the error.
