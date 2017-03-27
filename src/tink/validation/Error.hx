package tink.validation;

enum Error {
	MissingField(path: Array<String>);
	UnexpectedType(path: Array<String>, expectedType:Dynamic, actualValue:Dynamic);
}
