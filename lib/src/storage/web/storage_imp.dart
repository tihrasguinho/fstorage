// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:html' as html;

import '../storage.dart';
import '../../extensions/string_ext.dart';

const String _fStorageKey = 'dev.tihrasguinho.fStorage';

class StorageImp extends Storage {
  const StorageImp([String? path]);

  @override
  String? get path => null;

  @override
  Map<String, dynamic> load() {
    final source = html.window.localStorage[_fStorageKey]?.decodeFromBase64 ?? '{}';

    return jsonDecode(source);
  }

  @override
  void remove() {
    html.window.localStorage.remove(_fStorageKey);
  }

  @override
  void save(Map<String, dynamic> value) {
    html.window.localStorage.update(
      _fStorageKey,
      (_) => jsonEncode(value).encodeToBase64,
      ifAbsent: () => jsonEncode(value).encodeToBase64,
    );
  }
}
