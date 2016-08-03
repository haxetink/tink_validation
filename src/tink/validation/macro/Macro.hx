package tink.validation.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import tink.typecrawler.Crawler;
import tink.typecrawler.FieldInfo;
import tink.typecrawler.Generator;
import tink.macro.TypeMap;

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
		var t = getType('tink.validation.Extractor');
		var name = 'Extractor${counter++}';
		var ct = t.toComplex();
		var pos = Context.currentPos();
		
		var cl = macro class $name {
			public function new() {}
		}
		
		cl.meta.push({
			name: ':keep',
			pos: pos,
		});
		
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
	
	public static function buildValidator():Type
	{
		var t = getType('tink.validation.Validator');
		var name = 'Validator${counter++}';
		var ct = t.toComplex();
		var pos = Context.currentPos();
		
		var cl = macro class $name {
			public function new() {}
		}
		
		cl.meta.push({
			name: ':keep',
			pos: pos,
		});
		
		function add(t:TypeDefinition)
			cl.fields = cl.fields.concat(t.fields);
		
		var ret = Crawler.crawl(t, pos, GenValidator);
		cl.fields = cl.fields.concat(ret.fields);
		
		add(macro class {
			public function validate(value) @:pos(ret.expr.pos) {
				${ret.expr};
			}
			public function tryValidate(value)
				return tink.core.Error.catchExceptions(function() validate(value));
		});
		
		Context.defineType(cl);
		return Context.getType(name);
	}
}

