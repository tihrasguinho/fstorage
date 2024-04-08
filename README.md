### LOCAL STORAGE

##### Current types supported

* String (and List of Strings)
* Int (and List of Ints)
* Double (and List of Doubles)
* Bool (and List of Bools)
* DateTime (and List of DateTimes)
* Classes that extends `Entity`

##### How to use

1. Import `package:local_storage/local_storage.dart`
2. Use `LocalStorage.get` or `LocalStorage.put`
3. Use `LocalStorage.batch` to save multiple values at once

##### Create an `Entity` class

```dart
import 'package:local_storage/local_storage.dart';

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

  const User({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.image, 
    required this.age, 
    required this.weight, 
    required this.height, 
    required this.active, 
    required this.birthDate,
    });

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
```

##### Saving default types or `Entity` classes

```dart
void main() async {
    final storage = await LocalStorage.init();

    final user = User(
        id: 1,
        name: 'Tiago Alves',
        email: 'tiago@mail.com',
        image: null,
        age: 30,
        weight: 80.0,
        height: 1.84,
        active: true,
        birthDate: DateTime(1993, 9, 23),
    );

    storage.put<User>('user', user);

    final post = Post(
        0,
        title: 'Hello World',
        content: 'Lorem ipsum',
        owner: user,
        createdAt: DateTime.now(),
    );

    storage.put<Post>('post', post);

    storage.put<String>('string', 'Hello World');

    storage.put<int>('int', 1);

    storage.put<double>('double', 1.0);

    storage.put<bool>('bool', true);

    storage.put<DateTime>('datetime', DateTime.now());

    // OR

    storage.batch(
        (put) {
            put<User>('user', user);

            put<Post>('post', post);

            put<String>('string', 'Hello World');

            put<int>('int', 1);

            put<double>('double', 1.0);

            put<bool>('bool', true);

            put<DateTime>('datetime', DateTime.now());
        },
    );
}
```