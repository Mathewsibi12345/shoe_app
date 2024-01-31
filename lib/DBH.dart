import 'dart:developer';
import 'package:flutter_application_shoeadd/DB.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static const String tableName = 'shoes';

  DatabaseHelper._privateConstructor();//Private named constructor

  factory DatabaseHelper() {
    if (_instance == null) {
      _instance = DatabaseHelper._privateConstructor();
    }
    return _instance!;//_instance is being asserted to be non-null at that point in the code
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Database? _database; 
  // The null-aware access operator allows you to call a method or access a property on an object if 
 // the object is non-null. If the object is null, the entire expression evaluates to null.

  Future<Database> initDatabase() async {
    try {
      String path = join(await getDatabasesPath(), 'shoes_database.db');
      //function is used to retrieve the default path where databases should be stored
      return await openDatabase(path, version: 1,
          onCreate: (db, version) async {
        await db.execute('''
   CREATE TABLE $tableName (
     id INTEGER PRIMARY KEY AUTOINCREMENT,
     shoe_id TEXT,
     name TEXT,
     description TEXT,
     price REAL,
     imageUrl TEXT,
   )
''');
      }, onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      });
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> insertShoe(Shoe shoe) async {//insertShoe from add file
    try {
      final Database db = await database;
      log('shoe imageurl is ${shoe.imageUrl}');
      await db.insert(
        tableName,
        shoe.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
        //This means that if there is a conflict (for example, if the insertion would violate a unique constraint), 
        //the existing row with the same unique key will be replaced with the new data
     
      );
    } catch (e) {
      print('Error inserting shoe: $e');
      throw DatabaseException('Failed to insert shoe into the database.');
    }
  }

  Future<List<Shoe>> getShoes() async {
    try {
      final Database db = await database;
      final List<Map<String, dynamic>> maps = await db.query(tableName);
      return List.generate(maps.length, (i) {//generate a new list
      //along with the provided index to iterate through the maps
        return Shoe.fromMap(maps[i]);
        //It extracts values from the map to initialize the properties
      });
    } catch (e) {
      print('Error getting shoes: $e');
      throw DatabaseException('Failed to retrieve shoes from the database.');
    }
  }

  Future<void> close() async {
    try {
      final Database db = await database;
      db.close();
    } catch (e) {
      print('Error closing database: $e');
      throw DatabaseException('Failed to close the database.');
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}