library storage;

export 'io/storage_imp.dart' if (dart.library.html) 'web/storage_imp.dart' if (dart.library.io) 'io/storage_imp.dart';

abstract class Storage {
  final String? path;

  const Storage([this.path]);

  void save(Map<String, dynamic> value);
  void remove();
  Map<String, dynamic> load();
}
