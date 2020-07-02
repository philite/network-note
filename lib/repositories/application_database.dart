import 'package:sembast/sembast.dart';
import 'package:tekartik_common_utils/common_utils_import.dart';

class ApplicationDatabase {
  ApplicationDatabase(this._databaseFactory);

  final DatabaseFactory _databaseFactory;

  // Database
  static const String _databaseName = "network-note.db";
  static const int _kVersion1 = 1;
  final _lock = Lock(reentrant: true);
  Database _database;

  // Init database
  Future<Database> get initDatabase async =>
      _database ??= await _lock.synchronized(() async {
        if (_database == null) {
          await openPath(_databaseName);
        }
        return _database;
      });

  Future openPath(String path) async {
    _database = await _databaseFactory.openDatabase(path, version: _kVersion1);
  }

  Database get database => _database;
}
