// lib/services/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// تأكد من مسار هذا الاستيراد لكلاس CreatorItem
import '../../../../../../data/creatorsItems.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final documentsDirectory = await getDatabasesPath();
    final path = join(documentsDirectory, 'favorite_creators.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE creators(
        id INTEGER PRIMARY KEY,
        fullName TEXT,            -- عمود جديد
        profileImage TEXT,
        coverPhoto TEXT,
        storeName TEXT,
        deliveryValue REAL,
        rate REAL,
        rateCount INTEGER,
        address TEXT,             -- سيتم تخزينه كـ JSON string
        offers TEXT,              -- سيتم تخزينه كـ JSON string
        paymentMethods TEXT,      -- سيتم تخزينه كـ JSON string
        availability TEXT         -- سيتم تخزينه كـ JSON string
      )
    ''');
  }


  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {

    if (oldVersion < 2) {

      await db.execute('ALTER TABLE creators ADD COLUMN fullName TEXT;');
      await db.execute('ALTER TABLE creators ADD COLUMN offers TEXT;');
      await db.execute('ALTER TABLE creators ADD COLUMN paymentMethods TEXT;');
      await db.execute('ALTER TABLE creators ADD COLUMN availability TEXT;');
    }

  }

  Future<void> addFavoriteCreator(CreatorItem creator) async {
    final db = await database;
    await db.insert(
      'creators',
      creator.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavoriteCreator(int creatorId) async {
    final db = await database;
    await db.delete(
      'creators',
      where: 'id = ?',
      whereArgs: [creatorId],
    );
  }

  Future<bool> isCreatorFavorite(int creatorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'creators',
      where: 'id = ?',
      whereArgs: [creatorId],
    );
    return maps.isNotEmpty;
  }

  Future<List<CreatorItem>> getFavoriteCreators() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('creators');
    return List.generate(maps.length, (i) {
      return CreatorItem.fromMap(maps[i]);
    });
  }
}