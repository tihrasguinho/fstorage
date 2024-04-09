import 'package:checks/checks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstorage/fstorage.dart';

class StorageMock implements Storage {
  final Map<String, dynamic> _values;

  const StorageMock(this._values);

  @override
  Map<String, dynamic> load() => _values;

  @override
  String? get path => '';

  @override
  void remove() => _values.clear();

  @override
  void save(Map<String, dynamic> value) => _values.addAll(value);
}

void main() {
  late FStorage storage;
  late Map<String, dynamic> values;

  setUp(() async {
    values = {};
    storage = FStorage.fromStorage(StorageMock(values));
  });

  test('Expect save default types on FStorage', () async {
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

  test('Expect save an `Entity` on FStorage', () {
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

  test('Expect to save a list of default types on FStorage', () {
    storage.put<List<String>>('strings', ['hello', 'world']);
    storage.put<List<int>>('ints', [1, 2]);
    storage.put<List<double>>('doubles', [1.0, 2.0]);
    storage.put<List<bool>>('bools', [true, false]);
    storage.put<List<DateTime>>('dates', [DateTime(1993, 9, 23), DateTime(1993, 9, 24)]);

    // or batch

    storage.batch((put) {
      put<List<String>>('strings', ['hello', 'world']);
      put<List<int>>('ints', [1, 2]);
      put<List<double>>('doubles', [1.0, 2.0]);
      put<List<bool>>('bools', [true, false]);
      put<List<DateTime>>('dates', [DateTime(1993, 9, 23), DateTime(1993, 9, 24)]);
    });

    check(storage.get<List<String>>('strings')).isA<List<String>>().isNotEmpty();
    check(storage.get<List<int>>('ints')).isA<List<int>>().isNotEmpty();
    check(storage.get<List<double>>('doubles')).isA<List<double>>().isNotEmpty();
    check(storage.get<List<bool>>('bools')).isA<List<bool>>().isNotEmpty();
    check(storage.get<List<DateTime>>('dates')).isA<List<DateTime>>().isNotEmpty();
  });

  test('Expect an exception `NestedListException` by trying to save a nested list', () {
    check(
      () => storage.put<List<List<String>>>(
        'nestedStrings',
        [
          ['hello'],
          ['world']
        ],
      ),
    ).throws<NestedListException>();
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
