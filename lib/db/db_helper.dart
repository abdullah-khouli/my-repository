import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import '/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static const String _tableName = 'tasks';

  static Future<void> initDb() async {
    if (_db != null) {
      debugPrint('not null db');
      return;
    } else {
      try {
        String _path =
            await getDatabasesPath() + 'task.db'; //المسار الخاص بالداتا بيز
        debugPrint('in database path');
        _db = await openDatabase(
          _path,
          version: _version,
          onCreate: (Database db, int version) async {
            debugPrint('creating a new one');
            await db.execute(
              'CREATE TABLE $_tableName ('
              'id INTEGER PRIMARY KEY AUTOINCREMENT,'
              'title STRING ,note TEXT, date STRING,'
              'startTime STRING, endTime STRING,'
              'remind INTEGER, repeat STRING,'
              'color INTEGER ,'
              'isCompleted INTEGER)',
            );
          },
        );
      } catch (e) {
        print(e);
      }
    }
  }

  static Future<int> delete(int id) async {
    print('delete');

    return await _db!.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> query() async {
    print('query');
    return await _db!.query(_tableName);
  }

  static Future<int> insert(Task task) async {
    print('insert');
    return await _db!.insert(_tableName, task.toJson());
  }

  static Future<int> update(int id, int iscompleted) async {
    print('update');

    return await _db!.rawUpdate(
        '''
      UPDATE tasks
      SET isCompleted = ?
      WHERE id = ? 

     ''',
        [iscompleted, id]);
  }

  static deleteAll() async {
    await _db!.delete(_tableName);
  }
}
//ALTER TABLE sales_data AUTO_INCREMENT=1;