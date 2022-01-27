//d
import 'dart:math';

import 'package:sqflite/sqflite.dart';
import '/models/task.dart';

class DBHelper {
  static Database? _db;
  static const int _version = 1;
  static Future<List<Map<String, Object?>>> getListTasksID(
      {required String tableName}) async {
    final x = await _db!.query(tableName, columns: ['id']);

    return x;
  }

  static Future<List<Map<String, Object?>>> getListCompletedTasksID(
      {required String tableName}) async {
    final x = await _db!.query(tableName,
        columns: ['id'], where: 'isCompleted = ?', whereArgs: [1]);
    return x;
  }

  static Future<void> initDb() async {
    if (_db != null) {
      return;
    } else {
      try {
        String _path =
            await getDatabasesPath() + 'task.db'; //المسار الخاص بالداتا بيز

        _db = await openDatabase(
          _path,
          version: _version,
          onCreate: (Database db, int version) async {
            await db.execute(
              'CREATE TABLE tl0 ('
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

  static Future<void> deleteCompleted(String tableName) async {
    await _db!.delete(tableName, where: 'isCompleted = ?', whereArgs: [1]);
  }

  static Future<void> deleteTable(String tableName) async {
    await _db!.execute('DROP TABLE IF EXISTS $tableName');
  }

  static Future<void> createTable(String tableName) async {
    String x = tableName.toString();
    await _db!.execute(
      'CREATE TABLE $x ('
      'id INTEGER PRIMARY KEY AUTOINCREMENT,'
      'title STRING ,note TEXT, date STRING,'
      'startTime STRING, endTime STRING,'
      'remind INTEGER, repeat STRING,'
      'color INTEGER ,'
      'isCompleted INTEGER)',
    );
  }

  static Future<int> delete(int id, String tableName) async {
    return await _db!.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, dynamic>>> query(String tableName) async {
    return await _db!.query(tableName);
  }

  static Future<int> insertFromTableToTable(
      {required String currentTable,
      required String newTable,
      required int taskId}) async {
    List<Map<String, Object?>> listTask =
        await _db!.query(currentTable, where: 'id = ?', whereArgs: [taskId]);

    Map<String, Object?> task = listTask[0];
    Task newTask = Task.fromJson(task);
    newTask.id = null;

    return await _db!.insert(newTable, newTask.toJson());
  }

  static Future<int> insert(Task task, String tableName) async {
    return await _db!.insert(tableName, task.toJson());
  }

  static Future<int> update({
    required int id,
    int? iscompleted,
    String? title,
    String? note,
    String? date,
    String? repeat,
    int? remind,
    String? startTime,
    String? endTime,
    required String tableName,
  }) async {
    if (iscompleted != null) {
      return await _db!.rawUpdate('''
      UPDATE $tableName
      SET isCompleted = ?
      WHERE id = ? 

     ''', [iscompleted, id]);
    } else {
      return await _db!.rawUpdate('''
      UPDATE $tableName
      SET title = ? , note = ? , date = ? , remind = ? , repeat = ? , startTime = ? , endTime = ?
      WHERE id = ? 

     ''', [title, note, date, remind, repeat, startTime, endTime, id]);
    }
  }

  static deleteAll(String tableName) async {
    await _db!.delete(tableName);
  }
}
