package;

import haxe.unit.TestCase;
import haxe.unit.TestRunner;
import tink.Validation;

class RunTests extends TestCase
{
	static function main() 
	{
		var t = new TestRunner();
		t.add(new TestExtractor());
		t.add(new TestValidator());
		if(!t.run())
		{
			#if sys
			Sys.exit(500);
			#end
		}
	}
}
