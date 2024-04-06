import 'package:flutter_test/flutter_test.dart';
import 'package:local_storage/local_storage.dart';
import 'package:checks/checks.dart';

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

  test('Expect save default types on LocalStorage', () async {
    storage.put<String>('string', 'hello world');
    storage.put<int>('int', 1);
    storage.put<double>('double', 1.0);
    storage.put<bool>('bool', true);
    storage.put<DateTime>('datetime', DateTime(1993, 9, 23));

    check(storage.get<String>('string')).isA<String>().equals('hello world');
    check(storage.get<int>('int')).isA<int>().equals(1);
    check(storage.get<double>('double')).isA<double>().equals(1.0);
    check(storage.get<bool>('bool')).isA<bool>().equals(true);
    check(storage.get<DateTime>('datetime')).isA<DateTime>().equals(DateTime(1993, 9, 23));
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

    check(() => storage.put<User>('user', user)).throws<NotRegisteredException>();
  });

  test('Expect save an `Entity` on LocalStorage', () {
    storage.register<User>(User.new);

    final user = User(
      id: 1,
      name: 'Tiago Alves',
      email: 'tiago@mail.com',
      image: null,
      age: 30,
      weight: 80.5,
      height: 1.75,
      active: true,
      birthDate: DateTime(1993, 9, 23),
    );

    storage.put<User>('user', user);

    check(storage.get<User>('user')).isA<User>().equals(user);
  });

  test('Expect an exception `NotSupportedException` by not supported type', () {
    const something = Something();

    check(() => storage.put<Something>('something', something)).throws<NotSupportedException>();
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

    check(storage.get<String>('string')).isA<String>().equals('hello world');
    check(storage.get<int>('int')).isA<int>().equals(1);
    check(storage.get<double>('double')).isA<double>().equals(1.0);
    check(storage.get<bool>('bool')).isA<bool>().equals(true);
    check(storage.get<DateTime>('datetime')).isA<DateTime>().equals(DateTime(1993, 9, 23));
    check(storage.get<User>('user')).isA<User>().equals(user);
  });

  test('Expect to save a list of default types on LocalStorage', () {
    final strings = ['hello', 'world'];

    storage.put<List<String>>('strings', strings);

    check(storage.get<List<String>>('strings')).isA<List<String>>();
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
