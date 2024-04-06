import 'package:flutter/material.dart';
import 'package:local_storage/local_storage.dart';

late final LocalStorage storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  storage = await LocalStorage.init()
    ..clear();

  storage.register<User>(User.new);

  storage.register<Post>(Post.new);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('User: ${storage.get<User>('user')?.toJson()}'),
              const SizedBox(height: 16),
              Text('Post: ${storage.get<Post>('post')?.toJson()}'),
              Text('String: ${storage.get<String>('string')}'),
              const SizedBox(height: 16),
              Text('Int: ${storage.get<int>('int')}'),
              const SizedBox(height: 16),
              Text('Double: ${storage.get<double>('double')}'),
              const SizedBox(height: 16),
              Text('Bool: ${storage.get<bool>('bool')}'),
              const SizedBox(height: 16),
              Text('DateTime: ${storage.get<DateTime>('datetime')}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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

            setState(() {});
          },
        ),
      ),
    );
  }
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

class Post extends Entity {
  final int id;
  final String title;
  final String content;
  final User owner;
  final DateTime createdAt;

  const Post(
    this.id, {
    required this.title,
    required this.content,
    required this.owner,
    required this.createdAt,
  });

  @override
  Map<Symbol, dynamic> get properties => {
        #id: id,
        #title: title,
        #content: content,
        #owner: owner,
        #createdAt: createdAt,
      };
}
