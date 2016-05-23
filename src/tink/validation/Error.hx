package tink.validation;

enum Error {
	MissingField(field:String);
	UnexpectedType(expectedType:Dynamic, actualValue:Dynamic);
}