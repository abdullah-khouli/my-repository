//d
import 'package:flutter/material.dart';
import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:get/get.dart';
import 'package:to_do_app/controllers/task_controller.dart';

import 'home_page.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TaskController _taskController = Get.put(TaskController());
    return EasySplashScreen(
      logo: Image.asset('images/appicon.jpeg'),
      title: const Text(
        'To Do',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      futureNavigator: Future(() async {
        await _taskController.loadTablesNamesFromGetStorage();
        await _taskController.getAllTasks();
        return Get.off<Object>(() => const HomePage(
              initialselectedList: 'My_Tasks',
            ))!;
      }),
    );
  }
}
