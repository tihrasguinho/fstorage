import 'dart:convert';

extension StringExt on String {
  String get encodeToBase64 => base64Encode(utf8.encode(this));
  String get decodeFromBase64 => utf8.decode(base64Decode(this));
}
