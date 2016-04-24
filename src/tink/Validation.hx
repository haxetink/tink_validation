package tink;

import haxe.macro.*;

#if macro
using tink.MacroApi;
#end

class Validation
{
	public static macro function extract(e:Expr) 
		return switch e {
			case macro ($e:$ct):
				macro new tink.validation.Extractor<$ct>().extract($e);
			case _:
				switch Context.getExpectedType() {
					case null:
						e.reject('Cannot determine expected type');
					case _.toComplex() => ct:
						macro @:pos(e.pos) new tink.validation.Extractor<$ct>().extract($e);
				}
		}
}