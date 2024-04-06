### LOCAL STORAGE

##### Examples

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