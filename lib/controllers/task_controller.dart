import 'package:get/get.dart';
import 'package:to_do_app/db/db_helper.dart';

import '../models/task.dart';

class TaskController extends GetxController {
  RxList<Task> taskList = <Task>[].obs;
  deleteAllTasks() async {
    await DBHelper.deleteAll();
    await getTasks();
    print(taskList.isEmpty);
  }

  Future<int> addTask({required Task task}) {
    return DBHelper.insert(
        task); //هون منخزن اوبجكت من الموديل تبعنا على شكل اوبجكت جسن بالداتا بيز
  }

  getTasks() async {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((data) => Task.fromJson(data)).toList());
    //هون منجيب ليست من اوبجكت جسون من الداتا بيز ومنحولها ل ليست من موديل اوبجكت اي ليست من تاسك
    print('get ttttttttttask');
  }

  deleteTasks(int id) async {
    await DBHelper.delete(id);
    getTasks();
  }

  markTaskCompleted(int id, int iscompleted) async {
    await DBHelper.update(id, iscompleted == 0 ? 1 : 0);
    getTasks();
  }
}
