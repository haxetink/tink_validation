package tink.validation;

import haxe.Int64;

@:genericBuild(tink.validation.macro.Macro.buildExtractor())
class Extractor<T> {}

class ExtractorBase {
	
	var path:Array<String>;
	public function new() {}
	
	function extractInt64(value:Dynamic) {
		if(Int64.isInt64(value)) return value;
		
		if(Std.is(value, Int)) {
			var v:Int = value;
			// TODO: not sure if we should treat high = v >> 32
			return Int64.make(0, v);
		}
		#if js
			if(Reflect.isObject(value) && Reflect.hasField(value, 'high') && Reflect.hasField(value, 'low')) {
				var high = Reflect.field(value, 'high');
				var low = Reflect.field(value, 'low');
				if(Std.is(high, Int) && Std.is(low, Int))
  					return Int64.make(high, low);
			}
		#end
		
		throw tink.validation.Error.UnexpectedType(path, 'Int64', value);
	}
}
