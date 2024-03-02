package tink.validation;

import haxe.Int64;

@:genericBuild(tink.validation.macro.Macro.buildValidator())
class Validator<T> {}

class ValidatorBase {
	
	var path:Array<String>;
	public function new() {}
	
	function validateInt64(value:Dynamic) {
		if(Int64.isInt64(value)) return;
		
		// if(Std.is(value, Int)) {
		// 	return;
		// }
		// #if js
		// 	if(Reflect.isObject(value) && Reflect.hasField(value, 'high') && Reflect.hasField(value, 'low')) {
		// 		var high = Reflect.field(value, 'high');
		// 		var low = Reflect.field(value, 'low');
		// 		if(Std.is(high, Int) && Std.is(low, Int))
  		// 			return;
		// 	}
		// #end
		
		throw tink.validation.Error.UnexpectedType(path, 'Int64', value);
	}
}
