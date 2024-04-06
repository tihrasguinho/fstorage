import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';

void main() {
  late LocalStorage storage;

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();

    storage = await LocalStorage.init();
  });

  test('local storage ...', () {
    storage.batch(
      (put) {
        put<String>('string', 'Hello World');
      },
    );
  });
}
