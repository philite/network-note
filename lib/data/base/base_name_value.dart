// Name-Value for json object

import 'package:tekartik_common_utils/model/model.dart';

abstract class BaseNameValueObject {
  // Identifier with id (Sembast has auto-increment)
  final id = BaseNameValue<int>('id');

  // Think of this class as 1 json object with many name-value pairs

  // Can't use pair because of Dart's class Pair is already exists!
  List<BaseNameValue> get objectAttributes;

  // Simply 'from Json' (If no input then use this pairs)
  void fromMap(Map map, {List<BaseNameValue> inputAttributes, int id}) {
    // Change this identifier
    this.id.value = id;
    inputAttributes ??= this.objectAttributes;
    var model = Model(map);
    for (var attribute in inputAttributes) {
      var entry = model.getModelEntry(attribute.name);
      if (entry != null) {
        attribute.value = entry.value;
      }
    }
  }

  // 'to Json'
  Model toMap({List<BaseNameValue> attributes}) {
    attributes ??= this.objectAttributes;
    var model = Model();
    for (var attribute in attributes) {
      model.setValue(attribute.name, attribute.value,
          presentIfNull: attribute.hasValue);
    }
    return model;
  }
}

class BaseName<T> {
  BaseName(this.name);
  final String name;
}

// # Functions to create pair of name-value

// String as value data type
BaseNameValue<String> toStringNameValue(String name) =>
    BaseNameValue<String>(name);

// Int as value data type
BaseNameValue<int> toIntNameValue(String name) => BaseNameValue<int>(name);

class BaseNameValue<T> extends BaseName<T> {
  BaseNameValue(this._name) : super(_name);

  String _name;
  T _value;
  bool _hasValue = false;

  // For name
  String get name => _name;

  // For value
  T get value => _value;

  set value(T value) {
    _hasValue = true;
    _value = value;
  }

  bool get isNull => _value == null;

  bool get hasValue => _hasValue;
}
