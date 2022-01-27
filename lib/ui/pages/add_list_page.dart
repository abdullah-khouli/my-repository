//d
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/ui/pages/home_page.dart';
import 'package:to_do_app/ui/theme.dart';

class AddTaskList extends StatefulWidget {
  final String previousListName;
  const AddTaskList({
    Key? key,
    required this.previousListName,
  }) : super(key: key);
  @override
  State<AddTaskList> createState() => _AddTaskListState();
}

class _AddTaskListState extends State<AddTaskList> {
  final TextEditingController _controller = TextEditingController();
  final TaskController _taskController = Get.put(TaskController());

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.isDarkMode ? Colors.black87 : Colors.white70,
      appBar: AppBar(
        title: Text(
          'Create-new-list'.tr,
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        elevation: 1,
        backgroundColor: context.theme.backgroundColor,
        leading: IconButton(
          onPressed: () => Get.off(
              () => HomePage(initialselectedList: widget.previousListName)),
          icon: Icon(
            Icons.cancel,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _controller.text.trim().isEmpty
                ? null
                : () async {
                    if (_controller.text.length > 30)
                      Get.snackbar(
                        'Error'.tr,
                        'Name Mustn\'t contains more then 30 charactar '.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.white,
                        colorText: pinkClr,
                        icon: const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                      );
                    else {
                      await _taskController
                          .createTableForNewList(_controller.text.trim());
                      Get.off(() => HomePage(
                          initialselectedList: _controller.text.trim()));
                    }
                  },
            child: Text(
              'Done'.tr,
              style: subTitleStyle.copyWith(
                color:
                    _controller.text.trim().isEmpty ? Colors.grey : primaryClr,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: context.theme.backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: TextFormField(
          maxLines: null,
          controller: _controller,
          onChanged: (title) => setState(() {}),
          style: subTitleStyle,
          autofocus: true,
          cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
          decoration: InputDecoration(
            hintText: 'Enter-list-name'.tr,
            hintStyle: subTitleStyle,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: 0, color: context.theme.scaffoldBackgroundColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  color: context.theme.scaffoldBackgroundColor, width: 0),
            ),
          ),
        ),
      ),
    );
  }
}
