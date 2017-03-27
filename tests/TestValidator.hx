package;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Validation;
import tink.validation.Validator;
import TestEnum;

class TestValidator extends TestCase {
	
	function testDate() {
		var now = new Date(2016,1,1,1,1,1);
		var source:Dynamic = {date: now, other: now, extra: "now"};
		try {
			Validation.validate((source:{date:Date, ?other:Date, ?optional:Date}));
			assertTrue(true);
		} catch (e:Dynamic) {
			fail('should be valid');
		}
	}
	
	function testEnum()
	{
		var arr = ['1', '2', '3'];
		var e = EnumA(1, arr);
		var source:Dynamic = {e: e};
		try {
			Validation.validate((source:{e:TestEnum}));
			assertTrue(true);
		} catch (e:Dynamic) {
			fail('should be valid');
		}
		
		try {
			var source:Dynamic = {e: "string"};
			Validation.validate((source:{e:TestEnum}));
			fail('should be invalid');
		} catch(e:Dynamic) {
			assertTrue(true);
		}
	}
	
	function testDynamic()
	{
		var source:Dynamic = {date: Date.now(), float: 1.1, string: '1', array: [1,2,3]};
		
		try {
			Validation.validate((source:{date:Dynamic, float:Dynamic, string:Dynamic, array:Dynamic}));
			assertTrue(true);
		} catch (e:Dynamic) {
			fail('should be valid');
		}
	}
	
	function testComplex()
	{
		var source:Dynamic= {a:1, b:2, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));

			assertTrue(Reflect.hasField(source, 'c'));
			assertEquals(2, source.b);
			assertEquals("c", source.c);
			assertTrue(Reflect.hasField(source, 'd'));
			assertTrue(Reflect.hasField(source, 'e'));

			assertEquals(2, source.f.length);
			assertEquals(1, source.f[0].a);
			assertEquals(2, source.f[1].a);

			assertFalse(Reflect.hasField(source, 'g'));
		} catch (e:Dynamic) {
			fail('should be valid');
		}

		// b is missing
		source = {a:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			fail('should fail');
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'MissingField');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 1 && path[0] == 'b');
		} catch (e:Dynamic) {
			fail('should fail but not like that');
		}

		// f.a is missing (array)
		source = {a:1, b:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			fail('should fail');
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'MissingField');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 3 && path.join('.') == 'f.0.a');
		} catch (e:Dynamic) {
			fail('should fail but not like that');
		}

		// d.c is missing (anonymous)
		source = {a:1, b:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, d:{c: String}, f:Array<{a:Int}>, ?g:Bool}));
			fail('should fail');
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'MissingField');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 2 && path.join('.') == 'd.c');
		} catch (e:Dynamic) {
			fail('should fail but not like that');
		}

		// b is a String
		source = {a:1, b:'b', c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			fail('should fail');
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 1 && path.join('.') == 'b');
			assertTrue(Type.enumParameters(e)[1] == Float);
			assertTrue(Type.enumParameters(e)[2] == 'b');
		} catch (e:Dynamic) {
			fail('should fail but not like that');
		}

		// f.a is a String
		source = untyped {a:1, b:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:'a'},{a:2}]};
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			fail('should fail');
		} catch (e:tink.validation.Error) {
			assertTrue(Type.enumConstructor(e) == 'UnexpectedType');
			var path: Array<String> = Type.enumParameters(e)[0];
			assertTrue(path.length == 3 && path.join('.') == 'f.0.a');
			assertTrue(Type.enumParameters(e)[1] == Int);
			assertTrue(Type.enumParameters(e)[2] == 'a');
		} catch (e:Dynamic) {
			fail('should fail but not like that');
		}
	}

	function testWithValidator() {
	  var validator = new Validator<{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}>();
	  try {
		validator.validate(cast {a:1, c:"c", d:{a:1, b:1}, e:{a:1, b:1}, f:[{a:1},{a:2}]});
	  } catch(e: tink.validation.Error) {
		assertTrue(Type.enumConstructor(e) == 'MissingField');
		var path: Array<String> = Type.enumParameters(e)[0];
		assertTrue(path.length == 1 && path[0] == 'b');
		try {
		  validator.validate(cast {a:1, c:"c", b:1, d:{a:1, b:1}, e:{a:1, b:1}});
		} catch(e: tink.validation.Error) {
		  assertTrue(Type.enumConstructor(e) == 'MissingField');
		  var path: Array<String> = Type.enumParameters(e)[0];
		  assertTrue(path.length == 1 && path[0] == 'f');
		}
	  } catch (e: Dynamic) {
		fail('should fail but not like that');
	  }
	}
	
	function fail( reason:String, ?c : haxe.PosInfos ) : Void {
		currentTest.done = true;
		currentTest.success = false;
		currentTest.error   = reason;
		currentTest.posInfos = c;
		throw currentTest;
	}
}
