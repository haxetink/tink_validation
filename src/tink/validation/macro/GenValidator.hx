package tink.validation.macro;

import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.FieldInfo;

using haxe.macro.Tools;
using tink.MacroApi;
using tink.CoreApi;

class GenValidator {

  public function new() {
  }

	public function wrap(placeholder:Expr, ct:ComplexType)
		return placeholder.func(['value'.toArg(ct)], false);
		
	public function nullable(e)
		return macro if(value != null) $e else null;
		
	public function string()
		return macro if(!Std.is(value, String)) throw tink.validation.Error.UnexpectedType(path, String, value);
		
	public function int()
		return macro if(!Std.is(value, Int)) throw tink.validation.Error.UnexpectedType(path, Int, value);
		
	public function float()
		return macro if(!Std.is(value, Float)) throw tink.validation.Error.UnexpectedType(path, Float, value);
		
	public function bool()
		return macro if(!Std.is(value, Bool)) throw tink.validation.Error.UnexpectedType(path, Bool, value);
		
	public function date()
		return macro if(!Std.is(value, Date)) throw tink.validation.Error.UnexpectedType(path, Date, value);
		
	public function bytes()
		return macro if(!Std.is(value, haxe.io.Bytes)) throw tink.validation.Error.UnexpectedType(path, haxe.io.Bytes, value);
		
	public function map(k, v)
		return macro if(!Std.is(value, Map)) throw tink.validation.Error.UnexpectedType(path, Map, value);
		
	public function anon(fields:Array<FieldInfo>, ct)
		return macro {
			$b{[for(f in fields) {
				var name = f.name;
				var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw tink.validation.Error.MissingField(path);
				macro {
					path.push($v{name});
					$assert;
					var value = value.$name;
					${f.expr};
					path.pop();
				}
			}]}
			return null;
		}
		
	public function array(e:Expr)
	{
		return macro {
			if(!Std.is(value, Array)) throw tink.validation.Error.UnexpectedType(path, Array, value);
			[for(value in (value:Array<Dynamic>)) $e];
		}
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
		return macro if(!Std.is(value, $p{name})) throw tink.validation.Error.UnexpectedType(path, $p{name}, value);
	}
		
	public function dyn(_, _)
		return macro null;
		
	public function dynAccess(_)
		return macro null;
		
	public function reject(t:Type)
		return 'Cannot validate ${t.toString()}';
		
	public function rescue(t:Type, _, _)
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
}
