abstract class FStorageException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const FStorageException(this.message, [this.stackTrace]);
}

class NotSupportedException extends FStorageException {
  const NotSupportedException(super.message, [super.stackTrace]);
}

class NotRegisteredException extends FStorageException {
  const NotRegisteredException(super.message, [super.stackTrace]);
}

class InvalidException extends FStorageException {
  const InvalidException(super.message, [super.stackTrace]);
}

class NestedListException extends FStorageException {
  const NestedListException([String? message, StackTrace? stackTrace]) : super(message ?? 'Nested list is not supported', stackTrace);
}
