//d
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do_app/db/db_helper.dart';

import '../models/task.dart';

class TaskController extends GetxController {
  final GetStorage _box = GetStorage();
  Map<String, dynamic> tablesListsNames = {'My_Tasks': 'tl0'};
  Map<String, RxList<Task>> tasksLists = {'My_Tasks': <Task>[].obs};

  Future<void> createTableForNewList(String listName) async {
    List x = tablesListsNames.values.toList();
    int number = int.parse(x[x.length - 1].toString().split('l')[1]) + 1;
    await DBHelper.createTable('tl$number');
    tasksLists.addAll({listName: <Task>[].obs});
    tablesListsNames.addAll({listName: 'tl$number'});
    await _box.write('tablesNames', tablesListsNames);
  }

  loadTablesNamesFromGetStorage() {
    if (_box.read('tablesNames') != null) {
      var x = _box.read('tablesNames')!;
      tablesListsNames = x;
    }
  }

  deleteTasks(int id, String listName) async {
    await DBHelper.delete(id, tablesListsNames[listName]!);
  }

  deleteAllTasks(String listName) async {
    await DBHelper.deleteAll(tablesListsNames[listName]!);
  }

  Future<List<int>> deleteAllTasksListNotifications(
      {required String listName, bool? isCompleted}) async {
    List<Map<String, Object?>> listOfMapOfId;
    if (isCompleted == null)
      listOfMapOfId =
          await DBHelper.getListTasksID(tableName: tablesListsNames[listName]!);
    else
      listOfMapOfId = await DBHelper.getListCompletedTasksID(
          tableName: tablesListsNames[listName]!);
    final List<int> listOfId =
        listOfMapOfId.map((e) => int.parse(e['id']!.toString())).toList();
    return listOfId;
  }

  Future<List<int>> deleteAllCompletedTasksListNotifications(
      {required String listName}) async {
    final listOfMapOfId =
        await DBHelper.getListTasksID(tableName: tablesListsNames[listName]!);

    final List<int> listOfId =
        listOfMapOfId.map((e) => int.parse(e['id']!.toString())).toList();
    return listOfId;
  }

  deleteCompletedTasks(String listName) async {
    await DBHelper.deleteCompleted(tablesListsNames[listName]!);
  }

  deleteLsit(String listName) async {
    await DBHelper.deleteTable(tablesListsNames[listName]!);
    tablesListsNames.remove(listName);
    await _box.write('tablesNames', tablesListsNames);
  }

  Future<int> addTask({required Task task, required String listName}) {
    return DBHelper.insert(
        task,
        tablesListsNames[
            listName]!); //هون منخزن اوبجكت من الموديل تبعنا على شكل اوبجكت جسن بالداتا بيز
    //هون علقت بمشكلة انو بدي استدعي الgetTasks
    //بس ماقدرت بسبب ال return
  }

  Future<void> getTasks({required String listName}) async {
    //استدعاء الكويري من اجل ليست واحدة
    final List<Map<String, dynamic>> tasks =
        await DBHelper.query(tablesListsNames[listName]!);
    tasksLists[listName]!
        .assignAll(tasks.map((data) => Task.fromJson(data)).toList());
    //هون منجيب ليست من اوبجكت جسون من الداتا بيز ومنحولها ل ليست من موديل اوبجكت اي ليست من تاسك
  }

  Future<void> getAllTasks() async {
    List<String> listNames = tablesListsNames.keys.toList();

    for (String _listNames in listNames) {
      if (_listNames != 'My_Tasks')
        tasksLists.addAll({_listNames: <Task>[].obs});
      await getTasks(listName: _listNames);
    }
  }

  markTaskCompleted(int id, int iscompleted, String listName) async {
    await DBHelper.update(
        id: id,
        iscompleted: iscompleted == 0 ? 1 : 0,
        tableName: tablesListsNames[listName]!);
  }

  updateTask({
    required int id,
    required String title,
    required String note,
    required String listName,
    required String date,
    required String repeat,
    required int remind,
    required String startTime,
    required String endTime,
  }) async {
    await DBHelper.update(
      id: id,
      tableName: tablesListsNames[listName]!,
      title: title,
      note: note,
      date: date,
      remind: remind,
      repeat: repeat,
      startTime: startTime,
      endTime: endTime,
    );
  }

  moveTaskFromTableToAnother(
      {required String currentList,
      required String newList,
      required int taskId}) async {
    await DBHelper.insertFromTableToTable(
        currentTable: tablesListsNames[currentList]!,
        newTable: tablesListsNames[newList]!,
        taskId: taskId);
  }
}
