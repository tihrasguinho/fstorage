abstract class LocalStorageException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const LocalStorageException(this.message, [this.stackTrace]);
}

class NotSupportedException extends LocalStorageException {
  const NotSupportedException(super.message, [super.stackTrace]);
}

class NotRegisteredException extends LocalStorageException {
  const NotRegisteredException(super.message, [super.stackTrace]);
}

class InvalidException extends LocalStorageException {
  const InvalidException(super.message, [super.stackTrace]);
}

class NestedListException extends LocalStorageException {
  const NestedListException([String? message, StackTrace? stackTrace]) : super(message ?? 'Nested list is not supported', stackTrace);
}
