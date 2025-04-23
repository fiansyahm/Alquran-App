import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('prayer_notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE notification_settings (
      prayer_name TEXT PRIMARY KEY,
      sound_option TEXT NOT NULL
    )
    ''');
  }

  Future<void> insertOrUpdateSetting(String prayerName, String soundOption) async {
    final db = await database;
    await db.insert(
      'notification_settings',
      {'prayer_name': prayerName, 'sound_option': soundOption},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final result = await db.query('notification_settings');
    Map<String, String> settings = {};
    for (var row in result) {
      settings[row['prayer_name'] as String] = row['sound_option'] as String;
    }
    return settings;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}