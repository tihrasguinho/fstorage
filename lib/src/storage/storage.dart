import 'dart:convert';
import 'dart:io';

import 'package:local_storage/src/extensions/string_ext.dart';
import 'package:universal_html/html.dart' as html;

const String _localStorageKey = 'dev.tihrasguinho.local_storage';
const _empty = '{}';

abstract class Storage {
  final String? path;

  const Storage([this.path]);

  void save(Map<String, dynamic> value);
  void remove();
  Map<String, dynamic> load();
}

final class StorageWeb extends Storage {
  StorageWeb();

  @override
  String? get path => null;

  @override
  Map<String, dynamic> load() {
    final source = html.window.localStorage[_localStorageKey]?.decodeFromBase64 ?? '{}';

    return jsonDecode(source);
  }

  @override
  void remove() {
    html.window.localStorage.remove(_localStorageKey);
  }

  @override
  void save(Map<String, dynamic> value) {
    html.window.localStorage.update(
      _localStorageKey,
      (_) => jsonEncode(value).encodeToBase64,
      ifAbsent: () => jsonEncode(value).encodeToBase64,
    );
  }
}

final class StorageNative extends Storage {
  final String filePath;

  const StorageNative(this.filePath);

  @override
  String? get path => filePath;

  @override
  Map<String, dynamic> load() {
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
      file.writeAsStringSync(_empty.encodeToBase64);
      return jsonDecode(_empty);
    } else {
      return jsonDecode(file.readAsStringSync().decodeFromBase64);
    }
  }

  @override
  void remove() {
    final file = File(filePath);
    if (file.existsSync()) return file.writeAsStringSync(_empty.encodeToBase64);
  }

  @override
  void save(Map<String, dynamic> value) {
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file.writeAsStringSync(jsonEncode(value).encodeToBase64);
  }
}
