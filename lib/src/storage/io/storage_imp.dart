import 'dart:convert';
import 'dart:io';

import '../storage.dart';
import '../../extensions/string_ext.dart';

const _empty = '{}';

class StorageImp extends Storage {
  final String filePath;

  const StorageImp(this.filePath);

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
