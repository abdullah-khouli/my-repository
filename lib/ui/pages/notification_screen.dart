//d
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/models/task.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/size_config.dart';
import 'package:to_do_app/ui/theme.dart';
import 'package:intl/date_symbol_data_local.dart';

class NotificationScreen extends StatefulWidget {
  final Task task_;
  final String listName;
  const NotificationScreen({
    Key? key,
    required this.task_,
    required this.listName,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TaskController _taskController = Get.put(TaskController());
  final notifiHelper = NotifyHelper();
  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _noteController = TextEditingController();
  late Task task;
  late String listName;
  RxString newSelectedList = ''.obs;
  late Rx<DateTime> _selectedDate;
  late Rx<String> _selectedRepeat;
  late Rx<int> _selectedRemind;
  late Rx<int> isCompleted;
  late Rx<String> _startTime;
  late Rx<String> _endTime;
  List<String> repeatLsit = ['None', 'Hourly', 'Daily', 'Weekly'];
  List<int> remindList = [0, 5, 10, 15, 20];
  @override
  void initState() {
    initializeDateFormatting();
    task = widget.task_;
    listName = widget.listName; //widget.task_.split('|')[5];
    isCompleted = widget.task_.isCompleted!.obs;
    _titleController.text = widget.task_.title!; //_payload.split('|')[0];
    _noteController.text = widget.task_.note!; //_payload.split('|')[1];
    newSelectedList.value = widget.listName; //_payload.split('|')[5];
    _selectedDate = DateTime.parse(widget.task_.date!)
        .obs; //DateTime.parse(_payload.split('|')[6]).obs;
    _selectedRemind =
        widget.task_.remind!.obs; //int.parse(_payload.split('|')[8]).obs;
    _selectedRepeat = widget.task_.repeat!.obs; //_payload.split('|')[7].obs;
    _startTime = widget.task_.startTime!.obs;
    _endTime = widget.task_.endTime!.obs;
    super.initState();
  }

  TextFormField buildTextField(TextEditingController _controller,
      FontWeight _fontWeight, double _fontSize) {
    return TextFormField(
      readOnly: isCompleted.value == 1 ? true : false,
      autofocus: false,
      focusNode: FocusNode(canRequestFocus: false),
      textAlign:
          Get.locale.toString() == 'en' ? TextAlign.left : TextAlign.right,
      maxLines: null,
      style: TextStyle(
          color: Get.isDarkMode ? Colors.white.withOpacity(0.8) : darkGreyClr,
          fontSize: _fontSize,
          fontWeight: _fontWeight),
      cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[700],
      controller: _controller,
      decoration: InputDecoration(
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(width: 0, color: context.theme.backgroundColor),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(width: 0, color: context.theme.backgroundColor),
        ),
      ),
    );
  }

  _getDateFromUser() async {
    DateTime? _pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (_pickedDate != null)
      _selectedDate.value = _pickedDate;
    else {}
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

      if (isStartTime)
        _startTime.value = formattedTime;
      else
        _endTime.value = formattedTime;
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        alignment: Alignment.centerRight,
        height: 60,
        padding: const EdgeInsets.only(right: 10),
        width: double.infinity,
        child: TextButton(
            onPressed: () async {
              await _taskController.markTaskCompleted(
                task.id!, // int.parse(_payload.split('|')[3]),
                isCompleted.value, // int.parse(_payload.split('|')[4]),
                listName, // _payload.split('|')[5],
              );
              await _taskController.getTasks(
                listName: listName, //_payload.split('|')[5],
              );
              setState(() {
                isCompleted.value = (isCompleted.value == 0) ? 1 : 0;
              });
            },
            child: Obx(
              () => Text(
                isCompleted.value == 0 ? 'Mark completed' : 'Mark uncompleted',
                style: bodyStyle.copyWith(color: primaryClr),
              ),
            )),
      ),
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () async {
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
              if (_titleController.text != task.title //_payload.split('|')[0]
                  ||
                  _noteController.text != task.note // _payload.split('|')[1]
                  ||
                  _selectedDate.value !=
                      DateTime.parse(task
                          .date!) //       DateTime.parse(_payload.split('|')[6])
                  ||
                  _selectedRemind.value !=
                      task.remind //int.parse(_payload.split('|')[8])
                  ||
                  _selectedRepeat.value != task.repeat //_payload.split('|')[7]
                  ||
                  _startTime.value != task.startTime ||
                  _endTime.value != task.endTime) {
                try {
                  print(_startTime);
                  await _taskController.updateTask(
                    id: task.id!, //int.parse(_payload.split('|')[3]),
                    title: _titleController.text,
                    note: _noteController.text,
                    listName: listName, //  _payload.split('|')[5],
                    date: DateFormat('yyyy-MM-dd').format(
                        _selectedDate.value), //   _payload.split('|')[6],
                    repeat: _selectedRepeat.value, //_payload.split('|')[7],
                    remind: _selectedRemind
                        .value, //int.parse(_payload.split('|')[8]),
                    startTime: _startTime.value,
                    endTime: _endTime.value,
                  );
                  var date = DateFormat.jm().parse(_startTime.value).subtract(
                      //استخدمنا هاد التنسيق لانو الستارت تايم مأخوذ من TimePicker
                      Duration(minutes: task.remind!));
                  var myTime = DateFormat('HH:mm').format(date);
                  var hour = int.parse(myTime.toString().split(':')[0]);
                  var minutes = int.parse(myTime.toString().split(':')[1]);
                  await notifiHelper.cancel(task.id!);
                  task.title = _titleController.text;
                  task.note = _noteController.text;
                  task.date =
                      DateFormat('yyyy-MM-dd').format(_selectedDate.value);
                  task.remind = _selectedRemind.value;
                  task.repeat = _selectedRepeat.value;
                  await notifiHelper.scheduledNotification(
                      hour, minutes, task, newSelectedList.value);

                  await _taskController.getTasks(
                      listName: listName //_payload.split('|')[5]
                      );
                  // throw ('tttt');
                } catch (e) {
                  Get.snackbar(
                    'Error'.tr,
                    'task not edited \n some thing went wrong'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.white,
                    colorText: pinkClr,
                    icon: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                    ),
                    isDismissible: true,
                    dismissDirection: SnackDismissDirection.HORIZONTAL,
                    // duration: const Duration(seconds: 5),
                  );
                }
              }
              if (newSelectedList.value != listName //_payload.split('|')[5]
                  ) {
                await _taskController.moveTaskFromTableToAnother(
                  currentList: listName, // _payload.split('|')[5],
                  newList: newSelectedList.value,
                  taskId: task.id!, //int.parse(_payload.split('|')[3])
                );
                _taskController.deleteTasks(
                  task.id!, //int.parse(_payload.split('|')[3]),
                  listName, // _payload.split('|')[5],
                );
                await _taskController.getTasks(
                  listName: listName, //        _payload.split('|')[5],
                );
                await _taskController.getTasks(listName: newSelectedList.value);
              }
              Get.back();
            }
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Colors.white : Colors.black45,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // cancel the notification with id value of zero

              var alertDialog = AlertDialog(
                title: Text(
                  'Warning'.tr,
                  style:
                      subHeadingStyle.copyWith(fontSize: 25, color: primaryClr),
                ),
                content: Text('DeleteTheTask?'.tr, style: titleStyle),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel'.tr,
                      style: body2Style,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        await notifiHelper.cancel(
                          task.id!,
                        );
                        await _taskController.deleteTasks(
                          task.id!,
                          listName,
                        );
                        await _taskController.getTasks(
                          listName: listName,
                        );

                        Navigator.pop(context);
                        Get.back();
                      } catch (e) {
                        Get.snackbar(
                          'Error'.tr,
                          'some thing went wrong'.tr,
                        );
                      }
                    },
                    child: Text(
                      'OK'.tr,
                      style: body2Style.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              );
              showDialog(context: context, builder: (ctx) => alertDialog);
            },
            icon: const Icon(Icons.delete_outline),
            color: Get.isDarkMode ? Colors.white : Colors.black45,
          )
        ],
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: isCompleted.value == 1
                    ? null
                    : () {
                        Get.bottomSheet(
                          Container(
                            padding: const EdgeInsets.only(top: 4),
                            width: SizeConfig.screenWidth,
                            color: Get.isDarkMode ? darkGreyClr : Colors.white,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  for (String name in _taskController
                                      .tablesListsNames.keys
                                      .toList())
                                    TextButton(
                                      onPressed: () {
                                        newSelectedList.value = name;
                                        Get.back();
                                      },
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 20),
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name.tr,
                                                overflow: TextOverflow.ellipsis,
                                                style: newSelectedList.value ==
                                                        name
                                                    ? subTitleStyle.copyWith(
                                                        color: primaryClr,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )
                                                    : subTitleStyle,
                                              ),
                                            ),
                                            if (newSelectedList.value == name)
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15.0),
                                                child: Icon(Icons.done,
                                                    color: primaryClr),
                                              ),
                                          ],
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        overlayColor:
                                            MaterialStateColor.resolveWith(
                                                (states) => Colors.grey
                                                    .withOpacity(0.15)),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                label: Icon(
                  Icons.arrow_drop_down,
                  color: isCompleted.value == 1 ? Colors.grey : primaryClr,
                ),
                icon: Obx(
                  () => Text(
                    newSelectedList.value.tr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color:
                            isCompleted.value == 1 ? Colors.grey : primaryClr,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.text_format,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child:
                        buildTextField(_titleController, FontWeight.w600, 20),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.description,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: buildTextField(_noteController, FontWeight.w400, 18),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.date_range,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: isCompleted.value == 1 ? null : _getDateFromUser,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //   color: Colors.red,
                        border: Border.all(color: Colors.grey),
                      ),
                      alignment: Get.locale.toString() == 'en'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Obx(
                        () => Text(
                          DateFormat.yMMMEd(Get.locale.toString())
                              .format(_selectedDate.value),
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : darkGreyClr,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.watch_later_outlined,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text('StartTime'.tr + ' :  ',
                      textAlign: Get.locale.toString() == 'en'
                          ? TextAlign.left
                          : TextAlign.right,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : darkGreyClr,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: isCompleted.value == 1
                        ? null
                        : () => _getTimeFromUser(isStartTime: true),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //   color: Colors.red,
                        border: Border.all(color: Colors.grey),
                      ),
                      alignment: Get.locale.toString() == 'en'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Obx(
                        () => Text(
                          _startTime.value,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : darkGreyClr,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.watch_later_outlined,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Text('EndTime'.tr + ' :  ',
                      textAlign: Get.locale.toString() == 'en'
                          ? TextAlign.left
                          : TextAlign.right,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : darkGreyClr,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  GestureDetector(
                    onTap: isCompleted.value == 1
                        ? null
                        : () => _getTimeFromUser(isStartTime: false),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        //   color: Colors.red,
                        border: Border.all(color: Colors.grey),
                      ),
                      alignment: Get.locale.toString() == 'en'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Obx(
                        () => Text(
                          _endTime.value,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : darkGreyClr,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.repeat,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text('Repeat'.tr + ' :  ',
                      textAlign: Get.locale.toString() == 'en'
                          ? TextAlign.left
                          : TextAlign.right,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : darkGreyClr,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  DropdownButton<String>(
                      hint: Obx(
                        () => Text(
                          _selectedRepeat.value.tr,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : darkGreyClr,
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
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
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color:
                            isCompleted.value == 1 ? Colors.grey : primaryClr,
                      ),
                      iconSize: 25,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      onChanged: isCompleted.value == 1
                          ? null
                          : (String? newValue) {
                              _selectedRepeat.value = newValue!;
                            },
                      style: subTitleStyle),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  SizedBox(
                    width: 30,
                    child: Icon(
                      Icons.watch_later_outlined,
                      size: 25,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Text('RemindBefore'.tr + ' :  ',
                      textAlign: Get.locale.toString() == 'en'
                          ? TextAlign.left
                          : TextAlign.right,
                      style: TextStyle(
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.8)
                              : darkGreyClr,
                          fontSize: 16,
                          fontWeight: FontWeight.w800)),
                  DropdownButton<int>(
                      iconDisabledColor: Colors.grey,
                      hint: Obx(() => Text(
                          '${_selectedRemind.value}'.tr + 'Minutes'.tr,
                          textAlign: Get.locale.toString() == 'en'
                              ? TextAlign.left
                              : TextAlign.right,
                          style: TextStyle(
                              color: Get.isDarkMode
                                  ? Colors.white.withOpacity(0.8)
                                  : darkGreyClr,
                              fontSize: 15,
                              fontWeight: FontWeight.w500))),
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: primaryClr,
                      items: remindList
                          .map<DropdownMenuItem<int>>(
                            (e) => DropdownMenuItem<int>(
                              value: e,
                              child: Text(
                                e.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color:
                            isCompleted.value == 1 ? Colors.grey : primaryClr,
                      ),
                      iconSize: 25,
                      elevation: 4,
                      underline: Container(
                        height: 0,
                      ),
                      onChanged: isCompleted.value == 1
                          ? null
                          : (int? newValue) {
                              _selectedRemind.value = newValue!;
                            },
                      style: subTitleStyle),
                ],
              ),
              const SizedBox(height: 65),
            ],
          ),
        ),
      ),
      // const SizedBox(height: 10),
    );
  }
}
