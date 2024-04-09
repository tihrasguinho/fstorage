library fstorage;

export 'src/entity.dart';
export 'src/storage/storage.dart';
export 'src/exceptions.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'src/class.dart';
import 'src/entity.dart';
import 'src/exceptions.dart';
import 'src/fstorage_base.dart';
import 'src/parameter.dart';
import 'src/storage/storage.dart';

bool _isTypeOf<T, S>() => <T>[] is List<S>;

class FStorage implements FStorageBase {
  final Storage _storage;
  final Map<Type, Class> _classes;
  final Map<String, dynamic> _values;

  FStorage._(this._storage, this._classes, this._values);

  FStorage.fromStorage(Storage storage) : this._(storage, <Type, Class>{}, <String, dynamic>{});

  static Future<FStorage> getInstance() async {
    final storage = StorageImp(p.join((await getApplicationSupportDirectory()).path, 'fStorage', 'database'));

    return FStorage._(storage, <Type, Class>{}, storage.load());
  }

  @override
  T? get<T>(String key) {
    if (_isTypeOf<T, Entity>()) {
      if (!_classes.containsKey(T)) {
        throw NotRegisteredException('Class ${T.toString()} not registered!');
      }

      final cls = _classes[T]!;

      final parameters = cls.parameters;

      final map = _load();

      final source = map[key];

      if (source == null) return null;

      final sourceParameters = Map<String, dynamic>.from(source['parameters']);

      if (sourceParameters.length != parameters.length) return null;

      _extractValues(parameters, sourceParameters);

      return cls.invoke(parameters) as T;
    } else {
      final map = _load();

      final source = map[key];

      if (source == null) return null;

      final sourceMap = Map<String, dynamic>.from(source);

      if (sourceMap['list'] != null) {
        final listMap = Map<String, dynamic>.from(sourceMap['list']);

        final list = switch (listMap['type']) {
          'String' when listMap['nullable'] == false => (sourceMap['value'] as List).cast<String>(),
          'String' when listMap['nullable'] == true => (sourceMap['value'] as List).cast<String?>(),
          'int' when listMap['nullable'] == false => (sourceMap['value'] as List).cast<int>(),
          'int' when listMap['nullable'] == true => (sourceMap['value'] as List).cast<int?>(),
          'double' when listMap['nullable'] == false => (sourceMap['value'] as List).cast<double>(),
          'double' when listMap['nullable'] == true => (sourceMap['value'] as List).cast<double?>(),
          'bool' when listMap['nullable'] == false => (sourceMap['value'] as List).cast<bool>(),
          'bool' when listMap['nullable'] == true => (sourceMap['value'] as List).cast<bool?>(),
          'DateTime' when listMap['nullable'] == false => (sourceMap['value'] as List).map((e) => DateTime.fromMillisecondsSinceEpoch(e)).toList(),
          'DateTime' when listMap['nullable'] == true => (sourceMap['value'] as List).map((e) => e != null ? DateTime.fromMillisecondsSinceEpoch(e) : null).toList(),
          _ => throw NotSupportedException('Unsuported type of list ${sourceMap['type']}!'),
        };

        return list as T;
      } else {
        switch (sourceMap['type']) {
          case 'String':
            {
              if (sourceMap['nullable'] == false) {
                return sourceMap['value'] as T;
              } else {
                return sourceMap['value'] as T;
              }
            }
        }

        final value = switch (sourceMap['type']) {
          'String' when sourceMap['nullable'] == false => sourceMap['value'] as String,
          'String' when sourceMap['nullable'] == true => sourceMap['value'] as String?,
          'int' when sourceMap['nullable'] == false => sourceMap['value'] as int,
          'int' when sourceMap['nullable'] == true => sourceMap['value'] as int?,
          'double' when sourceMap['nullable'] == false => sourceMap['value'] as double,
          'double' when sourceMap['nullable'] == true => sourceMap['value'] as double?,
          'bool' when sourceMap['nullable'] == false => sourceMap['value'] as bool,
          'bool' when sourceMap['nullable'] == true => sourceMap['value'] as bool?,
          'DateTime' when sourceMap['nullable'] == false => DateTime.fromMillisecondsSinceEpoch(sourceMap['value'] as int),
          'DateTime' when sourceMap['nullable'] == true => sourceMap['value'] != null ? DateTime.fromMillisecondsSinceEpoch(sourceMap['value'] as int) : null,
          _ => throw NotSupportedException('Unsupported type ${sourceMap['type']}!'),
        };

        return value as T;
      }
    }
  }

  @override
  void put<T>(String key, T value) {
    _save({key: _put<T>(key, value)});
  }

  @override
  void batch(void Function(void Function<T>(String key, T value) put) func) {
    final temp = <String, dynamic>{};
    func(<T>(String key, T value) => temp[key] = _put<T>(key, value));
    return _save(temp);
  }

  @override
  void register<T extends Entity>(Function constructor) {
    if (['dynamic', 'Object', 'Object?'].contains(T.toString())) throw InvalidException('Invalid type $T!');

    final constructorString = constructor.runtimeType.toString();

    final splited = constructorString.split(' => ');

    final typeString = splited.last.trim();

    if (typeString != T.toString()) throw const InvalidException('Invalid constructor type');

    final stringParams = splited.first.replaceAll(RegExp(r'(\(|\[|\]|\))'), '').trim();

    final positionalParameters = List<PositionalParameter>.from(
      stringParams.replaceAll(RegExp(r'{(.+)}'), '').split(', ').where((item) => item.isNotEmpty).map(
        (item) {
          return PositionalParameter(
            type: item.trim().replaceAll('?', ''),
            nullable: item.trim().endsWith('?'),
          );
        },
      ),
    );

    final namedParameters = List<NamedParameter>.from(
      RegExp(r'{(.+)}').firstMatch(stringParams)?.group(1)?.split(', ').map(
            (item) {
              final regex = RegExp(r'(required )?([\<\w\?\>]+)\s([\w]+)');

              return NamedParameter(
                type: regex.firstMatch(item)?.group(2)?.replaceAll('?', '') ?? '',
                nullable: regex.firstMatch(item)?.group(2)?.endsWith('?') ?? false,
                named: Symbol(regex.firstMatch(item)?.group(3) ?? ''),
              );
            },
          ) ??
          [],
    );

    final params = List<Parameter>.from(
      [
        ...positionalParameters,
        ...namedParameters,
      ],
    );

    _classes[T] = Class(type: T, constructor: constructor, parameters: params);
  }

  @override
  void clear() => _clear();

  @override
  bool containsKey(String key) {
    final map = _load();
    return map.containsKey(key);
  }

  @override
  void delete(String key) {
    final map = _load();
    map.remove(key);
    return _save(map);
  }

  Map<String, dynamic> _put<T>(String key, T value) {
    if (_isTypeOf<T, Entity>()) {
      final entity = value as Entity;

      if (!_classes.containsKey(T)) {
        throw NotRegisteredException('Class ${T.toString()} not registered!');
      }

      final cls = _classes[T]!;

      final (properties, parameters) = _normalizeParametersAndProps(entity.properties, cls.parameters);

      _extractProps(properties, parameters);

      final map = <String, dynamic>{};

      for (var i = 0; i < parameters.length; i++) {
        final param = parameters[i];

        map[i.toString()] = {
          'type': param.type.replaceAll('?', ''),
          'nullable': param.nullable,
          'value': param.value,
        };
      }

      return <String, dynamic>{
        'type': T.toString().replaceAll('?', ''),
        'nullable': T.toString().endsWith('?'),
        'parameters': map,
      };
    } else {
      final isList = T.toString().startsWith('List');

      if (isList) {
        final (:type, rounds: _) = _typeListFromString(T.toString());

        if (type case 'dynamic' || 'Object' || 'Object?') {
          throw InvalidException('Invalid type of list $T!');
        }

        switch (type) {
          case 'String' || 'String?':
          case 'int' || 'int?':
          case 'double' || 'double?':
          case 'bool' || 'bool?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'list': {
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
              },
              'value': value,
            };
          case 'DateTime' || 'DateTime?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'list': {
                'type': type.replaceAll('?', ''),
                'nullable': type.endsWith('?'),
              },
              'value': (value as List).map((e) => e?.millisecondsSinceEpoch).toList(),
            };
          default:
            throw NotSupportedException('Unsupported type $T!');
        }
      } else {
        switch (T.toString()) {
          case 'String' || 'String?':
          case 'int' || 'int?':
          case 'double' || 'double?':
          case 'bool' || 'bool?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'value': value,
            };
          case 'DateTime' || 'DateTime?':
            return {
              'type': T.toString().replaceAll('?', ''),
              'nullable': T.toString().endsWith('?'),
              'value': (value as DateTime).millisecondsSinceEpoch,
            };
          default:
            throw NotSupportedException('Unsupported type $T!');
        }
      }
    }
  }

  void _extractProps(Set props, List<Parameter> parameters) {
    if (props.length != parameters.length) {
      throw const InvalidException('Wrong number of parameters!');
    }

    for (var i = 0; i < props.length; i++) {
      final prop = props.elementAt(i);
      final param = parameters[i];

      parameters[i] = param.setValue(_propToDynamic(prop));
    }
  }

  void _extractValues(List<Parameter> parameters, Map<String, dynamic> sourceParameters) {
    for (var i = 0; i < parameters.length; i++) {
      final parameter = parameters[i];

      if (_classes.keys.any((key) => key.toString() == parameter.type)) {
        final sourceParameter = Map<String, dynamic>.from(sourceParameters[i.toString()]['value']);
        final innerCls = _classes.entries.firstWhere((entry) => entry.key.toString() == parameter.type).value;
        final innerParameters = innerCls.parameters;
        final innerSourceParameters = Map<String, dynamic>.from(sourceParameter['parameters']);

        _extractValues(innerParameters, innerSourceParameters);

        parameters[i] = parameter.setValue(innerCls.invoke(innerParameters));
      } else {
        final sourceParameter = Map<String, dynamic>.from(sourceParameters[i.toString()]);

        parameters[i] = switch (parameter.type) {
          'String' when sourceParameter['type'] == 'String' => parameter.setValue(sourceParameter['value']),
          'List<String>' when sourceParameter['type'] == 'List<String>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => e.toString()).toList(),
            ),
          'int' when sourceParameter['type'] == 'int' => parameter.setValue(sourceParameter['value']),
          'List<int>' when sourceParameter['type'] == 'List<int>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => int.parse(e.toString())).toList(),
            ),
          'double' when sourceParameter['type'] == 'double' => parameter.setValue(sourceParameter['value']),
          'List<double>' when sourceParameter['type'] == 'List<double>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => double.parse(e.toString())).toList(),
            ),
          'bool' when sourceParameter['type'] == 'bool' => parameter.setValue(sourceParameter['value']),
          'List<bool>' when sourceParameter['type'] == 'List<bool>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => bool.parse(e.toString())).toList(),
            ),
          'DateTime' when sourceParameter['type'] == 'DateTime' => parameter.setValue(
              sourceParameter['value'] == null ? null : DateTime.fromMillisecondsSinceEpoch(sourceParameter['value']),
            ),
          'List<DateTime>' when sourceParameter['type'] == 'List<DateTime>' => parameter.setValue(
              sourceParameter['value'] == null ? null : (sourceParameter['value'] as List).map((e) => DateTime.fromMillisecondsSinceEpoch(e)).toList(),
            ),
          _ => throw NotSupportedException('Unsupported type: ${parameter.type}'),
        };
      }
    }
  }

  dynamic _propToDynamic(dynamic prop) {
    if (prop is List) {
      String? listType = _getListType(prop);
      if (listType?.endsWith('?') ?? false) {
        listType = listType?.substring(0, listType.length - 1);
      }
      switch (listType) {
        case 'String':
        case 'int':
        case 'double':
        case 'bool':
          return prop;
        case 'DateTime':
          return prop.map((e) => (e as DateTime).millisecondsSinceEpoch).toList();
        default:
          throw NotSupportedException('Unknown type: ${prop.runtimeType}');
      }
    } else if (prop is Entity) {
      if (!_classes.containsKey(prop.runtimeType)) {
        throw NotRegisteredException('Class ${prop.runtimeType} not registered!');
      }

      final innerCls = _classes[prop.runtimeType]!;

      final (properties, parameters) = _normalizeParametersAndProps(prop.properties, innerCls.parameters);

      _extractProps(properties, parameters);

      return {
        'type': innerCls.type.toString().replaceAll('?', ''),
        'nullable': innerCls.type.toString().endsWith('?'),
        'parameters': parameters.asMap().entries.fold(
          <String, dynamic>{},
          (prev, next) => {
            ...prev,
            next.key.toString(): {
              'type': next.value.type.toString().replaceAll('?', ''),
              'nullable': next.value.nullable,
              'value': next.value.value,
            }
          },
        ),
      };
    } else {
      switch (prop.runtimeType.toString().replaceAll('?', '')) {
        case 'String':
        case 'int':
        case 'double':
        case 'bool':
        case 'Null':
          return prop;
        case 'DateTime':
          return (prop as DateTime).millisecondsSinceEpoch;
        default:
          throw NotSupportedException('Unknown type: ${prop.runtimeType}');
      }
    }
  }

  Map<String, dynamic> _load() {
    if (_values.isEmpty) {
      _values.clear();
      _values.addAll(_storage.load());
    }
    return _values;
  }

  void _save(Map<String, dynamic> map) {
    _values.addAll(map);
    _storage.save(_values);
  }

  void _clear() {
    _values.clear();
    _storage.save(_values);
  }

  String? _getListType(List list) {
    try {
      var temp = list;
      temp.add(_placeholder);
      return null;
    } catch (e) {
      return RegExp(r"type '(.+)' is not a subtype of type '(.+)' of '(.+)'").firstMatch(e.toString())?.group(2);
    }
  }

  (Set properties, List<Parameter> parameters) _normalizeParametersAndProps(Map<Symbol, dynamic> properties, List<Parameter> parameters) {
    if (_storage.path != null) {
      return (properties.values.toSet(), parameters);
    }

    final positionalParameters = parameters.whereType<PositionalParameter>().toList();

    final namedParameters = [];

    for (var i = 0; i < properties.length; i++) {
      final named = parameters.whereType<NamedParameter>().toList();
      final property = properties.entries.elementAt(i);

      if (named.any((parameter) => parameter.named == property.key)) {
        final index = named.indexWhere((parameter) => parameter.named == property.key);
        namedParameters.add(named[index]);
      }
    }

    namedParameters.sort((a, b) => a.named.toString().compareTo(b.named.toString()));

    final params = <Parameter>[...positionalParameters, ...namedParameters];

    final props = properties.entries.toList();

    final namedProps = props.where((element) => namedParameters.any((e) => e.named == element.key)).toList();

    namedProps.sort((a, b) => a.key.toString().compareTo(b.key.toString()));

    final finalProps = [
      ...props.where((e) => !namedProps.contains(e)),
      ...namedProps,
    ].map((e) => e.value).toSet();

    return (finalProps, params);
  }

  ({String type, int rounds}) _typeListFromString(String listType, [int rounds = 1]) {
    final regex = RegExp(r'List<(.+)>');
    final match = regex.firstMatch(listType);
    if (match == null) {
      throw Exception('Invalid list type $listType!');
    } else {
      final type = match.group(1);
      if (type?.startsWith('List') == true) {
        throw const NestedListException();
      } else {
        return (type: type!, rounds: rounds);
      }
    }
  }
}

final class _FStoragePlaceholder {
  final int timestamp;
  const _FStoragePlaceholder(this.timestamp);
}

const _placeholder = _FStoragePlaceholder(1234567890);
