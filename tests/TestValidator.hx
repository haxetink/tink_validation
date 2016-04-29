package;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Validation;
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
		Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
		
		try {
			Validation.validate((source:{?c:String, b:Float, f:Array<{a:Int}>, ?g:Bool}));
			assertTrue(true);
		} catch (e:Dynamic) {
			fail('should be valid');
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
