package anon;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.Crawler;
import tink.typecrawler.FieldInfo;
import tink.typecrawler.Generator;

using haxe.macro.Tools;
using tink.MacroApi;

class Macro
{
	static var counter = 0;
	
	static function getType(name)
		return 
			switch Context.getLocalType() {
				case TInst(_.toString() == name => true, [v]): v;
				default: throw 'assert';
			}
	
	public static function buildExtractor():Type
	{
		var t = getType('anon.Extractor');
		var name = 'Extractor${counter++}';
		var ct = t.toComplex();
		var pos = Context.currentPos();
		
		var cl = macro class $name {
			public function new() {}
		}
		
		function add(t:TypeDefinition)
			cl.fields = cl.fields.concat(t.fields);
		
		var ret = Crawler.crawl(t, pos, GenExtractor);
		cl.fields = cl.fields.concat(ret.fields);
		
		add(macro class {
			public function extract(value) @:pos(ret.expr.pos) {
				return ${ret.expr};
			}
			public function tryExtract(value)
				return tink.core.Error.catchExceptions(function() return extract(value));
		});
		
		Context.defineType(cl);
		return Context.getType(name);
	}
}

class GenExtractor {
	static public function args()
		return ['value'];
		
	static public function nullable(e)
		return macro if(value != null) $e else null;
		
	static public function string()
		return macro if(!Std.is(value, String)) throw 'The value `' + value + '` should be String' else value;
		
	static public function int()
		return macro if(!Std.is(value, Int)) throw 'The value `' + value + '` should be Int' else value;
		
	static public function float()
		return macro if(!Std.is(value, Float)) throw 'The value `' + value + '` should be Float' else value;
		
	static public function bool()
		return macro if(!Std.is(value, Bool)) throw 'The value `' + value + '` should be Bool' else value;
		
	static public function date()
		return macro if(!Std.is(value, Date)) throw 'The value `' + value + '` should be Date' else value;
		// TODO: should make a copy? i.e. `Date.fromTime(value.getTime())`
		
	static public function bytes()
		return macro throw "Not supported";
		
	static public function map(k, v)
		return macro throw "Not supported";
		
	static public function anon(fields:Array<FieldInfo>, ct)
		return (macro function (value:$ct) {
			var __ret:Dynamic = {};
			$b{[for(f in fields) {
				var name = f.name;
				var assert = f.optional ? macro null : macro if(!Reflect.hasField(value, $v{name})) throw $v{'Field `${f.name}` should not be null'};
				macro {
					$assert;
					var value = value.$name;
					__ret.$name = ${f.expr};
				}
			}]}
			return __ret;
		}).getFunction().sure();
		
	static public function array(e:Expr)
	{
		return macro {
			if(!Std.is(value, Array)) throw 'The value `' + value + '` should be Array';
			[for(value in (value:Array<Dynamic>)) $e];
		}
	}
		
	static public function enm(constrictors:Array<EnumConstructor>, ct, _)
		return macro throw "Not supported";
		
	static public function dyn(_, _)
		return macro value;
		
	static public function dynAccess(_)
		return macro value;
		
	static public function reject(t:Type)
		return 'Cannot extract ${t.toString()}';
		
	static public function rescue(t:Type, _, _)
		return switch t {
			case TDynamic(t) if (t == null):
				Some(dyn(null, null));
			default: 
				None;
		}
}