//d
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/pages/home_page.dart';
import 'package:to_do_app/ui/theme.dart';
import 'package:to_do_app/ui/widgets/button.dart';
import 'package:to_do_app/ui/widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({
    Key? key,
    required this.listName,
  }) : super(key: key);
  final String listName;
  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  final TaskController _taskCotroller = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(
        DateTime.now().add(
          const Duration(minutes: 15),
        ),
      )
      .toString();

  int _selectedRemind = 0;
  List<int> remindList = [0, 5, 10, 15, 20];
  String _selectedRepeat = 'None';
  List<String> repeatLsit = ['None', 'Hourly', 'Daily', 'Weekly'];
  int _selectedColor = 0;
  late int hour;
  late int minutes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'AddTask'.tr,
                style: headingStyle,
              ),
              InputField(
                autofocus: true,
                title: 'Title'.tr,
                hint: 'EnterTitleHere'.tr,
                controller: _titleController,
              ),
              InputField(
                title: 'Note'.tr,
                hint: 'EnterNoteHere'.tr,
                controller: _noteController,
              ),
              InputField(
                title: 'Date'.tr,
                hint: DateFormat.yMd().format(_selectedDate),
                widget: IconButton(
                  onPressed: () => _getDateFromUser(),
                  icon: const Icon(
                    Icons.date_range,
                    color: primaryClr,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: InputField(
                      title: 'StartTime'.tr,
                      hint: _startTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: true),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: primaryClr,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: InputField(
                      title: 'EndTime'.tr,
                      hint: _endTime,
                      widget: IconButton(
                        onPressed: () => _getTimeFromUser(isStartTime: false),
                        icon: const Icon(
                          Icons.access_time_rounded,
                          color: primaryClr,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              InputField(
                title: 'Remind'.tr,
                hint: _selectedRemind == 0
                    ? 'None'.tr
                    : Get.locale.toString() == 'ar'
                        ? 'MinutesEarly'.tr + '  $_selectedRemind '
                        : '$_selectedRemind  ' + 'MinutesEarly'.tr,
                widget: Padding(
                  padding: const EdgeInsets.only(right: 6, left: 6),
                  child: DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: primaryClr,
                      items: remindList
                          .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem<String>(
                              value: e.toString(),
                              child: Text(
                                '$e',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: primaryClr,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRemind = int.parse(newValue!);
                        });
                      },
                      style: subTitleStyle),
                ),
              ),
              InputField(
                title: 'Repeat'.tr,
                hint: _selectedRepeat.tr,
                widget: Padding(
                  padding: const EdgeInsets.only(right: 6, left: 6),
                  child: DropdownButton(
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: primaryClr,
                      items: repeatLsit
                          .map<DropdownMenuItem<String>>(
                            (e) => DropdownMenuItem<String>(
                              value: e,
                              child: Text(
                                e.tr,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: primaryClr,
                      ),
                      iconSize: 32,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRepeat = newValue!;
                        });
                      },
                      style: subTitleStyle),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _colorPalette(),
                  MyButton(
                      label: 'CreateTask'.tr,
                      onTap: () async {
                        await _validateDate();
                      })
                ],
              ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      leading: IconButton(
        onPressed: () {
          Get.off(() => HomePage(
                initialselectedList: widget.listName,
              ));
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          size: 24,
          color: primaryClr,
        ),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      centerTitle: true,
    );
  }

  Future<void> _validateDate() async {
    if (_titleController.text.trim().isEmpty ||
        _noteController.text.trim().isEmpty) {
      Get.snackbar(
        'required'.tr,
        'All fields are required'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: pinkClr,
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: Colors.red,
        ),
        isDismissible: true,
        dismissDirection: SnackDismissDirection.HORIZONTAL,
      );
    } else {
      var date = DateFormat.jm().parse(_startTime).subtract(
          //استخدمنا هاد التنسيق لانو الستارت تايم مأخوذ من TimePicker
          Duration(minutes: _selectedRemind));

      var myTime = DateFormat('HH:mm').format(date);
      hour = int.parse(myTime.toString().split(':')[0]);
      minutes = int.parse(myTime.toString().split(':')[1]);
      var dateFormatted = DateTime(_selectedDate.year, _selectedDate.month,
          _selectedDate.day, hour, minutes);

      if (dateFormatted.isBefore(DateTime.now())) {
        if (_selectedRepeat == 'None' || _selectedRepeat == 'Daily') {
          _selectedDate = _selectedDate.add(const Duration(days: 1));
        } else if (_selectedRepeat == 'Weekly') {
          _selectedDate = _selectedDate.add(const Duration(days: 7));
        } else if (_selectedRepeat == 'Hourly') {
          _selectedDate = DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedDate.hour,
            _selectedDate.minute + 1,
          );
        } else
          print('errror');
      }

      await _addTasksToDb();
      //
      //Get.back();}

    }
  }

  _addTasksToDb() async {
    Task task = Task(
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      isCompleted: 0,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      startTime: _startTime,
      endTime: _endTime,
      color: _selectedColor,
      remind: _selectedRemind,
      repeat: _selectedRepeat,
    );
    int value =
        await _taskCotroller.addTask(task: task, listName: widget.listName);
    task.id = value;

    await NotifyHelper()
        .scheduledNotification(hour, minutes, task, widget.listName);
    await _taskCotroller.getTasks(listName: widget.listName);
    Get.off(() => HomePage(
          initialselectedList: widget.listName,
        ));
  }

  Column _colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color',
          style: titleStyle,
        ),
        const SizedBox(
          height: 8,
        ),
        Wrap(
            children: List<Widget>.generate(
          3,
          (index) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedColor = index;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 4),
              child: CircleAvatar(
                child: _selectedColor == index
                    ? const Icon(
                        Icons.done,
                        size: 16,
                        color: Colors.white,
                      )
                    : null,
                radius: 14,
                backgroundColor: index == 0
                    ? primaryClr
                    : index == 1
                        ? pinkClr
                        : orangeClr,
              ),
            ),
          ),
        ))
      ],
    );
  }

  _getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? _pickedTime = await showTimePicker(
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(
                const Duration(minutes: 15),
              ),
            ),
    );

    if (_pickedTime != null) {
      final String formattedTime = _pickedTime.format(context);

      setState(() {
        if (isStartTime)
          _startTime = formattedTime;
        else
          _endTime = formattedTime;
      });
    } else
      print('');
  }

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (_pickedDate != null)
      setState(() => _selectedDate = _pickedDate);
    else
      print('');
  }
}
