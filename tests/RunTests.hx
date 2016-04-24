package;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Validation;

class RunTests extends TestCase
{
	static function main() 
	{
		var t = new TestRunner();
		t.add(new RunTests());
		if(!t.run())
		{
			#if sys
			Sys.exit(500);
			#end
		}
	}
	
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
	}
}

