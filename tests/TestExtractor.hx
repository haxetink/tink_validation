package;

import haxe.Int64;
import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Validation;
import tink.validation.Extractor;
import TestEnum;

class TestExtractor extends TestCase
{
	function testDate()
	{
		var now = new Date(2016,1,1,1,1,1);
		var source:Dynamic = {date: now, other: now, extra: "now"};
		var r:{date:Date, ?other:Date, ?optional:Date} = Validation.extract(source);
		
		assertEquals(now.getTime(), r.date.getTime());
		assertEquals(now.getTime(), r.other.getTime());
		assertTrue(Reflect.hasField(r, "optional"));
		assertEquals(null, r.optional);
		assertFalse(Reflect.hasField(r, "extra"));
	}
	
	function testEnum()
	{
		var arr = ['1', '2', '3'];
		var e = EnumA(1, arr);
		var source:Dynamic = {e: e};
		var r:{e:TestEnum} = Validation.extract(source);
		
		switch r.e {
			case EnumA(int, array):
				assertEquals(1, int);
				assertEquals(arr.length, array.length);
				for(i in 0...arr.length) assertEquals(arr[i], array[i]);
		}
		
		try {
			var source:Dynamic = {e: "string"};
			var r:{e:TestEnum} = Validation.extract(source);
			assertTrue(false); // should not reach here
		} catch(e:Dynamic) assertTrue(true);
	}
	
	function testDynamic()
	{
		var source:Dynamic = {date: Date.now(), float: 1.1, string: '1', array: [1,2,3]};
		var r:{date:Dynamic, float:Dynamic, string:Dynamic, array:Dynamic} = Validation.extract(source);
		
		assertEquals(source.date, r.date);
		assertEquals(source.float, r.float);
		assertEquals(source.string, r.string);
		assertEquals(source.array, r.array);
	}
	
	function testComplex()
	{
		var source:Dynamic= {a:1, b:2, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		var r:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool} = Validation.extract(source);
		
		assertFalse(Reflect.hasField(r, 'a'));
		assertEquals(source.b, r.b);
		assertEquals(source.c, r.c);
		assertFalse(Reflect.hasField(r, 'd'));
		assertFalse(Reflect.hasField(r, 'e'));
		
		assertEquals(2, r.f.length);
		assertEquals(source.f[0].a, r.f[0].a);
		assertEquals(source.f[1].a, r.f[1].a);
		
		assertTrue(Reflect.hasField(r, 'g'));
		assertEquals(null, r.g);

		source = {a:1, b:'b', c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		try {
			var r:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool} = Validation.extract(source);
			assertTrue(false);
		} catch(e: tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 1 && path.join('.') == 'b');
			assertTrue(Type.enumParameters(e)[1] == Float);
			assertTrue(Type.enumParameters(e)[2] == 'b');
		} catch(e: Dynamic) {
			assertTrue(false);
		}

		// f.a is a String
		source = untyped {a:1, b:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:'a'},{a:2}]};
		
		try {
			Validation.extract((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			assertTrue(false);
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 3 && path.join('.') == 'f.0.a');
			assertTrue(Type.enumParameters(e)[1] == Int);
			assertTrue(Type.enumParameters(e)[2] == 'a');
		} catch (e:Dynamic) {
			assertTrue(false);
		}
	}
	
	function testInt64() {
		// var source:Dynamic= {i: Int64.make(1, 1)};
		var source:Dynamic= {
			#if js js: {high: 0x1ffff, low: 0x1ffff}, #end
			i: 0x1ffff,
			i64: Int64.make(0x1ffff, 0x1ffff),
		};
		var r:{
			#if js js:Int64, #end
			i:Int64,
			i64:Int64,
		} = Validation.extract(source);
		
		#if js assertTrue(r.js == Int64.make(0x1ffff, 0x1ffff)); #end
		assertTrue(r.i == Int64.make(0, 0x1ffff));
		assertTrue(r.i64 == Int64.make(0x1ffff, 0x1ffff));
	}

	function testWithExtractor() {
	  var extractor = new Extractor<{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}>();
	  try {
		extractor.extract(cast {a:1, b:1, c:1, d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]});
	  } catch(e: tink.validation.Error) {
		assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
		var path: Array<String> = Type.enumParameters(e)[0];
		assertTrue(path.length == 1 && path[0] == "c");
		try {
		  extractor.extract(cast {a:1, c:"c", b:"b", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]});
		} catch(e: tink.validation.Error) {
		  assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
		  var path: Array<String> = Type.enumParameters(e)[0];
		  assertTrue(path.length == 1 && path[0] == 'b');
		}
	  } catch (e: Dynamic) {
		assertTrue(false);
	  }
	}
}
