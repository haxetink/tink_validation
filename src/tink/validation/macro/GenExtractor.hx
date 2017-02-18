package tink.validation.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.FieldInfo;

using haxe.macro.Tools;
using tink.MacroApi;
using tink.CoreApi;

class GenExtractor {
	static public function wrap(placeholder:Expr, ct:ComplexType) 
		return placeholder.func(['value'.toArg(ct)]);
		
	static public function nullable(e)
		return macro if(value != null) $e else null;
		
	static public function string()
		return macro if(!Std.is(value, String)) throw tink.validation.Error.UnexpectedType(String, value) else value;
		
	static public function int()
		return macro if(!Std.is(value, Int)) throw tink.validation.Error.UnexpectedType(Int, value) else value;
		
	static public function float()
		return macro if(!Std.is(value, Float)) throw tink.validation.Error.UnexpectedType(Float, value) else value;
		
	static public function bool()
		return macro if(!Std.is(value, Bool)) throw tink.validation.Error.UnexpectedType(Bool, value) else value;
		
	static public function date()
		return macro if(!Std.is(value, Date)) throw tink.validation.Error.UnexpectedType(Date, value) else value;
		// TODO: should make a copy? i.e. `Date.fromTime(value.getTime())`
		
	static public function bytes()
		return macro if(!Std.is(value, haxe.io.Bytes)) throw tink.validation.Error.UnexpectedType(haxe.io.Bytes, value) else value;
		
	static public function map(k, v):Expr
		throw "unsupported";
		// return macro if(!Std.is(value, Map)) throw tink.validation.Error.UnexpectedType(Map, value) else value;
		
	static public function anon(fields:Array<FieldInfo>, ct)
		return macro {
			var __ret:Dynamic = {};
			$b{[for(f in fields) {
				var name = f.name;
				// var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw tink.validation.Error.MissingField($v{name});
				macro {
					// $assert;
					var value = value.$name;
					__ret.$name = ${f.expr};
				}
			}]}
			__ret;
		}
		
	static public function array(e:Expr)
		return macro {
			if(!Std.is(value, Array)) throw tink.validation.Error.UnexpectedType(Array, value);
			[for(value in (value:Array<Dynamic>)) $e];
		}
		
	static public function enm(_, ct, _, _) {
		var name = switch ct {
			case TPath({pack: pack, name: name, sub: sub}):
				var ret = pack.copy();
				ret.push(name);
				if(sub != null) ret.push(sub);
				ret;
			default: throw 'assert';
		}
		return macro if(!Std.is(value, $p{name})) throw tink.validation.Error.UnexpectedType($p{name}, value) else value;
	}
		
	static public function dyn(_, _)
		return macro value;
		
	static public function dynAccess(_)
		return macro value;
		
	static public function reject(t:Type)
		return 'Cannot extract ${t.toString()}';
		
	static public function rescue(t:Type, _, _) {
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
	}
}