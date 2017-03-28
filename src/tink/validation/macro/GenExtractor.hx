package tink.validation.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.FieldInfo;
import tink.typecrawler.Generator;

using haxe.macro.Tools;
using tink.MacroApi;
using tink.CoreApi;

class GenExtractor {

	public function new() {
	}

	public function wrap(placeholder:Expr, ct:ComplexType)
		return placeholder.func(['value'.toArg(ct)]);
		
	public function nullable(e)
		return macro if(value != null) $e else null;
		
	public function string()
		return macro if(!Std.is(value, String)) throw tink.validation.Error.UnexpectedType(path, String, value) else value;
		
	public function int()
		return macro if(!Std.is(value, Int)) throw tink.validation.Error.UnexpectedType(path, Int, value) else value;
		
	public function float()
		return macro if(!Std.is(value, Float)) throw tink.validation.Error.UnexpectedType(path, Float, value) else value;
		
	public function bool()
		return macro if(!Std.is(value, Bool)) throw tink.validation.Error.UnexpectedType(path, Bool, value) else value;
		
	public function date()
		return macro if(!Std.is(value, Date)) throw tink.validation.Error.UnexpectedType(path, Date, value) else value;
		// TODO: should make a copy? i.e. `Date.fromTime(value.getTime())`
		
	public function bytes()
		return macro if(!Std.is(value, haxe.io.Bytes)) throw tink.validation.Error.UnexpectedType(path, haxe.io.Bytes, value) else value;
		
	public function map(k, v):Expr
		throw "unsupported";
		// return macro if(!Std.is(value, Map)) throw tink.validation.Error.UnexpectedType(Map, value) else value;
		
	public function anon(fields:Array<FieldInfo>, ct)
		return macro {
			var __ret:Dynamic = {};
			$b{[for(f in fields) {
				var name = f.name;
				// var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw tink.validation.Error.MissingField($v{name});
				macro {
					// $assert;
					path.push($v{name});
					var value = value.$name;
					__ret.$name = ${f.expr};
					path.pop();
				}
			}]}
			__ret;
		}
		
	public function array(e:Expr)
		return macro {
			if(!Std.is(value, Array)) throw tink.validation.Error.UnexpectedType(path, Array, value);
			[for(i in 0...(value:Array<Dynamic>).length) {
				var value = (value:Array<Dynamic>)[i];
				path.push(Std.string(i));
				var __ret = $e;
				path.pop();
				__ret;
			}];
		}
		
	public function enm(_, ct, _, _) {
		var name = switch ct {
			case TPath({pack: pack, name: name, sub: sub}):
				var ret = pack.copy();
				ret.push(name);
				if(sub != null) ret.push(sub);
				ret;
			default: throw 'assert';
		}
		return macro if(!Std.is(value, $p{name})) throw tink.validation.Error.UnexpectedType(path, $p{name}, value) else {
			path.pop();
			value;
		};
	}
	
	public function enumAbstract(names:Array<String>, e:Expr):Expr
		throw 'not implemented';
		
	public function dyn(_, _)
		return macro value;
		
	public function dynAccess(_)
		return macro value;
		
	public function reject(t:Type)
		return 'Cannot extract ${t.toString()}';
		
	public function rescue(t:Type, _, _) {
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
	}
	 
	public function shouldIncludeField(c:ClassField, owner:Option<ClassType>):Bool
		return Helper.shouldIncludeField(c, owner);
	
	public function drive(type:Type, pos:Position, gen:Type->Position->Expr):Expr
		return gen(type, pos);
}
