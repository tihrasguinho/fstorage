// ignore_for_file: depend_on_referenced_packages

import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';

class StorageMock implements Storage {
  final Map<String, dynamic> _values;

  const StorageMock(this._values);

  @override
  Map<String, dynamic> load() => _values;

  @override
  String? get path => throw UnimplementedError();

  @override
  void remove() => _values.clear();

  @override
  void save(Map<String, dynamic> value) => _values.addAll(value);
}

void main() {
  late LocalStorage storage;
  late Map<String, dynamic> values;

  setUp(() async {
    values = {};
    storage = LocalStorage.fromStorage(StorageMock(values));
  });

  test('Expect save default types on LocalStorage', () {
    storage.put<String>('string', 'hello world');
    storage.put<int>('int', 1);
    storage.put<double>('double', 1.0);
    storage.put<bool>('bool', true);
    storage.put<DateTime>('datetime', DateTime(1993, 9, 23));

    expect(storage.get<String>('string'), allOf(isA<String>(), 'hello world'));
    expect(storage.get<int>('int'), allOf(isA<int>(), 1));
    expect(storage.get<double>('double'), allOf(isA<double>(), 1.0));
    expect(storage.get<bool>('bool'), allOf(isA<bool>(), true));
    expect(storage.get<DateTime>('datetime'), allOf(isA<DateTime>(), DateTime(1993, 9, 23)));
  });

  test('Expect an exception `NotRegisteredException` by not registering Entity', () {
    final user = User(
      id: 1,
      name: 'Tiago Alves',
      email: 'tiago@mail.com',
      image: 'image.png',
      age: 30,
      weight: 80.5,
      height: 1.75,
      active: true,
      birthDate: DateTime(1993, 9, 23),
    );

    expect(
      () => storage.put<User>('user', user),
      allOf(
        throwsException,
        throwsA(isA<NotRegisteredException>()),
      ),
    );
  });

  test('Expect save an `Entity` on LocalStorage', () {
    storage.register<User>(User.new);

    final user = User(
      id: 1,
      name: 'Tiago Alves',
      email: 'tiago@mail.com',
      image: 'image.png',
      age: 30,
      weight: 80.5,
      height: 1.75,
      active: true,
      birthDate: DateTime(1993, 9, 23),
    );

    storage.put<User>('user', user);

    expect(storage.get<User>('user'), allOf(isA<User>(), user));
  });

  test('Expect an exception `NotSupportedException` by not supported type', () {
    const something = Something();
    expect(
      () => storage.put<Something>('something', something),
      allOf(
        throwsException,
        throwsA(isA<NotSupportedException>()),
      ),
    );
  });

  test('Expect save multiple values in the same time using batch function', () {
    storage.register<User>(User.new);

    final user = User(
      id: 1,
      name: 'Tiago Alves',
      email: 'tiago@mail.com',
      image: 'image.png',
      age: 30,
      weight: 80.5,
      height: 1.75,
      active: true,
      birthDate: DateTime(1993, 9, 23),
    );

    storage.batch((put) {
      put<String>('string', 'hello world');
      put<int>('int', 1);
      put<double>('double', 1.0);
      put<bool>('bool', true);
      put<DateTime>('datetime', DateTime(1993, 9, 23));
      put<User>('user', user);
    });

    expect(storage.get<String>('string'), allOf(isA<String>(), 'hello world'));
    expect(storage.get<int>('int'), allOf(isA<int>(), 1));
    expect(storage.get<double>('double'), allOf(isA<double>(), 1.0));
    expect(storage.get<bool>('bool'), allOf(isA<bool>(), true));
    expect(storage.get<DateTime>('datetime'), allOf(isA<DateTime>(), DateTime(1993, 9, 23)));
    expect(storage.get<User>('user'), allOf(isA<User>(), user));
  });

  test('Expect to save a list of default types on LocalStorage', () {
    storage.put<List<String>>('strings', ['hello', 'world']);

    expect(
      storage.get<List<String>>('strings'),
      allOf(
        isA<List<String>>(),
        ['hello', 'world'],
      ),
    );
  });
}

class Something {
  const Something();
}

class User extends Entity {
  final int id;
  final String name;
  final String email;
  final String? image;
  final int age;
  final double weight;
  final double height;
  final bool active;
  final DateTime birthDate;

  User({required this.id, required this.name, required this.email, required this.image, required this.age, required this.weight, required this.height, required this.active, required this.birthDate});

  @override
  Map<Symbol, dynamic> get properties => {
        #id: id,
        #name: name,
        #email: email,
        #image: image,
        #age: age,
        #weight: weight,
        #height: height,
        #active: active,
        #birthDate: birthDate,
      };
}
