import 'dart:io';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/pages/notification_screen.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../services/theme_services.dart';
import '../../ui/widgets/button.dart';
import '../../ui/widgets/task_tile.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../size_config.dart';
import '../theme.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  final notifiHelper = NotifyHelper();
  DatePickerController? datePickerController = DatePickerController();
  bool showAllTasks = true;
  GlobalKey key = GlobalKey();
  late File _pickedFile;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  // bool showDateBar = true;
  ImageProvider<Object>? img;
  _pickImage({required ImageSource src}) async {
    final _image = await _picker.pickImage(source: src, imageQuality: 25);
    if (_image != null) {
      await _box.write('img', _image.path);
      _pickedFile = File(_image.path);
      setState(() {
        img = FileImage(_pickedFile);
      });
    }
  }

  List<Widget> tabs = <Widget>[
    const Tab(
      child: Text(
        'My Tasks',
      ),
      // height: 40,
    ),
    const Tab(
      // height: 40,
      child: Text(
        '+ New list',
      ),
    ),
    const Tab(
      // height: 40,
      child: Text(
        '+ New list',
      ),
    ),
    const Tab(
      // height: 40,
      child: Text(
        '+ New list',
      ),
    ),
  ];

  @override
  void initState() {
    print('iniiiiiit');
    _taskController.getTasks();
    if (_box.read('img') != null)
      img = FileImage(
        File(_box.read('img')),
      );

    //هون عمل هدول التلت خطوات انا عملتون بال main
    //بدال هون
    /* var notifyHelper = NotifyHelper();
    notifyHelper.requestIosPermissions();
    notifyHelper.initializeNotification();*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        bottomSheet: TextButton(onPressed: () {}, child: Text('test')),
        //bottomNavigationBar: _bottomNavigationBar(),
        backgroundColor: context.theme.backgroundColor,
        appBar: _appBar(),
        body: Column(
          children: [
            //  _addTaskBar(),
            !showAllTasks ? _addDateBar() : Container(),

            const SizedBox(height: 6),
            Expanded(
              child: TabBarView(
                children: [
                  _showTasks(),
                  Container(),
                  Container(),
                  Container(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(items: const [
      BottomNavigationBarItem(
          icon: Icon(Icons.ac_unit), label: '11', tooltip: 'Lists'),
      BottomNavigationBarItem(
          icon: Icon(Icons.ac_unit), label: '22', tooltip: 'Add Task'),
      BottomNavigationBarItem(
          icon: Icon(Icons.ac_unit), label: '33', tooltip: 'list options')
    ]);
  }

  AppBar _appBar() {
    return AppBar(
      bottom: TabBar(
        isScrollable: tabs.length > 3 ? true : false,
        indicatorColor: primaryClr,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: primaryClr,
        unselectedLabelColor: subTitleStyle.color,
        onTap: (index) => print(index),
        tabs: tabs,
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: CircleAvatar(
          child: GestureDetector(
            onTap: () async {
              await _pickImage(src: ImageSource.gallery);
            },
          ),
          backgroundImage: img ?? const AssetImage('images/person.jpeg'),
          radius: 30,
        ),
      ),
      elevation: 0.5,
      backgroundColor: context.theme.backgroundColor,
      actions: [
        if (!showAllTasks)
          IconButton(
            onPressed: () {
              setState(() {
                // _selectedDate = DateTime.now();
                datePickerController!.animateToDate(DateTime.now());
              });
            },
            icon: Icon(
              Icons.restart_alt_sharp,
              size: 18,
              color: Get.isDarkMode ? Colors.white : darkGreyClr,
            ),
          ),
        Obx(
          () => IconButton(
            onPressed: _taskController.taskList.isEmpty
                ? null
                : () {
                    var alertDialog = AlertDialog(
                      title: Text(
                        'warning',
                        style: subHeadingStyle.copyWith(fontSize: 25),
                      ),
                      content: Text('Delete all taks ?', style: titleStyle),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            'Cancel',
                            style: body2Style,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        TextButton(
                          child: Text(
                            'OK',
                            style: body2Style.copyWith(
                                fontWeight: FontWeight.w800),
                          ),
                          onPressed: () async {
                            try {
                              await notifiHelper.cancelAll();
                              await _taskController.deleteAllTasks();
                              Navigator.pop(context);
                            } catch (e) {
                              Get.snackbar(
                                'Error',
                                'tasks not deleted \n some thing went wrong',
                                duration: const Duration(seconds: 5),
                                isDismissible: true,
                                dismissDirection:
                                    SnackDismissDirection.HORIZONTAL,
                              );
                            }
                          },
                        ),
                      ],
                    );
                    showDialog(context: context, builder: (ctx) => alertDialog);
                  },
            icon: const Icon(
              Icons.delete_forever,
              size: 18,
            ),
            disabledColor: Colors.grey,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        IconButton(
          onPressed: () {
            ThemeServices().switchTheme();
          },
          icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            size: 18,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        PopupMenuButton(
          tooltip: 'show options',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(0),
          icon: Icon(
            Icons.more_vert,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
                height: 40,
                onTap: () => setState(() {
                      showAllTasks = true;
                    }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Show All Tasks',
                      style: bodyStyle,
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: showAllTasks
                          ? pinkClr
                          : Get.isDarkMode
                              ? Colors.white
                              : darkGreyClr,
                    ),
                  ],
                )),
            PopupMenuItem(
              height: 40,
              onTap: () => setState(() {
                showAllTasks = false;
              }),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter By Date',
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: !showAllTasks
                        ? pinkClr
                        : Get.isDarkMode
                            ? Colors.white
                            : darkGreyClr,
                  ),
                ],
              ),
            ),
            /*  PopupMenuItem(
                height: 40,
                onTap: () => setState(() {
                      showDateBar = !showDateBar;
                    }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showDateBar ? 'Hide Date Bar' : 'Show Date Bar',
                      style: bodyStyle,
                    ),
                    Icon(
                      showDateBar ? Icons.visibility : Icons.visibility_off,
                      size: 18,
                      color: Get.isDarkMode ? Colors.white : darkGreyClr,
                    ),
                  ],
                )),*/
          ],
        )
      ],
    );
  }

  Future<void> _onREfresh() async {
    TaskController().getTasks();
  }

  _addTaskBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: subHeadingStyle,
              ),
              Text(
                'Today',
                style: headingStyle,
              ),
            ],
          ),
          MyButton(
            label: '+ Add Task',
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
          )
        ],
      ),
    );
  }

  _addDateBar() {
    print('datepicker');
    return Container(
      margin: const EdgeInsets.only(top: 6, left: 20),
      child: /*HorizontalDatePickerWidget(
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          endDate: DateTime.now().add(const Duration(days: 500)),
          selectedDate: DateTime.now().add(Duration(days: 5)),
          widgetWidth: SizeConfig.screenWidth,
          datePickerController: datePickerController,
          normalColor: context.theme.backgroundColor,
          selectedColor: primaryClr,
          normalTextColor: Colors.grey,
        )*/
          DatePicker(
        DateTime.now(),
        controller: datePickerController,
        width: 70,
        height: 100,
        //activeDates: [DateTime.now(), DateTime(2030)],
        initialSelectedDate: DateTime.now(),
        selectedTextColor: Colors.white,
        dayTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        dateTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        selectionColor: primaryClr,
        onDateChange: (newDate) {
          setState(() {
            _selectedDate = newDate;
            debugPrint(_selectedDate.toString());
          });
        },
      ),
    );
  }

  Widget _showTasks() {
    return Container(
      child: Obx(
        () {
          if (_taskController.taskList.isEmpty) {
            return _noTaskMsg();
          } else {
            return RefreshIndicator(
              onRefresh: _onREfresh,
              child: ListView.builder(
                scrollDirection: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                itemBuilder: (context, index) {
                  var task = _taskController.taskList[index];
                  DateTime formattedDate = DateFormat('yyyy-MM-dd').parse(task
                      .date!); //هاد مشان قارن بين التاريخ المحدد وتاريخ التاسك بحيث يصيرو التنين نوع string
                  print('HPFormattedDate$formattedDate');
                  print('HPnow' + DateTime.now().toString());
                  print(
                      'cccccccccccccccccc${_selectedDate.isBefore(DateTime.now())}');
                  print(DateTime.now());
                  if (showAllTasks ||
                      formattedDate == _selectedDate || //none repeat condition
                      (formattedDate.isBefore(_selectedDate) &&
                          (task.repeat == 'Daily' || //daily condition
                              (task.repeat == 'Weekly' &&
                                  DateFormat('EEEE')
                                          .format(DateTime.parse(task.date!)) ==
                                      DateFormat('EEEE').format(
                                          _selectedDate)) || //weekly repeat condition
                              (task.repeat == 'Monthly' &&
                                  formattedDate.day ==
                                      _selectedDate
                                          .day //monthly repeat condition
                              )))) {
                    print('HPtaskDate${task.date}');
                    print('selectedDate$_selectedDate');
                    print('HPtaskStartTime' + task.startTime!);
                    //هون ضفت ال سبتراكت مشان برمجة الريمايند
                    // هون وقت استخدم هاد السطر عطا ايرور لان لازم يكون الستارت تايم معمول بشكل معين بالليست تبع التاسك حكا عنو بالفيديو بالوقت9:15

                    return AnimationConfiguration.staggeredList(
                      position:
                          index, //هاد البزسشن بدو انتجر بعبر عن مكان العنصر ضمن الليست
                      duration: const Duration(milliseconds: 1375),
                      child: SlideAnimation(
                        horizontalOffset: 300,
                        child: FadeInAnimation(
                          child: GestureDetector(
                            onTap: () => showBottomSheet(context, task),
                            child: TaskTile(task),
                          ),
                        ),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
                itemCount: _taskController.taskList.length,
              ),
            );
          }
        },
      ),
    );
  }

  Widget _noTaskMsg() {
    //هون عندي مشكلة ماعم يطلع الريفرش اندكاتر
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(microseconds: 2000),
          child: RefreshIndicator(
            onRefresh: _onREfresh,
            child: SingleChildScrollView(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 120),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 90,
                    color: primaryClr.withOpacity(0.5),
                    semanticsLabel: 'Task',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'You do not have any tasks yet!',
                      style: subHeadingStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      'Add new tasks to make your days productive',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }

  showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      LayoutBuilder(
        key: key,
        builder: (ctx, constraints) {
          print('constraintsmaxh${constraints.maxHeight}');
          print('constraintsminh${constraints.minHeight}');
          print('constraintsmaxw${constraints.maxWidth}');
          print('constraintsminw${constraints.minWidth}');
          return Container(
            padding: const EdgeInsets.only(top: 4),
            width: SizeConfig.screenWidth,
            height: (SizeConfig.orientation == Orientation.landscape)
                ? (task.isCompleted == 1
                    ? SizeConfig.screenHeight * 0.6
                    : SizeConfig.screenHeight * 0.8)
                : (task.isCompleted == 1

                    //هدول القيمتين حاطون بالفيديو 0.3 و 0.39 وانا غيرتون لان عطا اوفر فلو ومابعرف ليش ماعم يعمل سكرول مع انو حاطط سكرول
                    //بس بال لاند سكيب عم يعمل سكرول
                    ? SizeConfig.screenHeight * 0.3
                    : SizeConfig.screenHeight * 0.39),
            color: Get.isDarkMode ? darkGreyClr : Colors.white,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: 6,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildBottomSheet(
                    label: 'Show Task Details',
                    onTap: () async {
                      Get.back();
                      Get.to(() => NotificationScreen(
                          payload:
                              '${task.title}|${task.note}|${task.startTime}|${task.id}|${task.isCompleted}|'));
                    },
                    clr: primaryClr,
                  ),
                  task.isCompleted == 1
                      ? Container()
                      : _buildBottomSheet(
                          label: 'Task Completed',
                          onTap: () async {
                            print(task.id!);
                            _taskController.markTaskCompleted(
                                task.id!, task.isCompleted!);
                            // cancel the notification with id value of zero
                            notifiHelper.cancel(task.id!);
                            Get.back();
                          },
                          clr: primaryClr,
                        ),
                  _buildBottomSheet(
                    label: 'Delete Task',
                    onTap: () async {
                      // cancel the notification with id value of zero

                      var alertDialog = AlertDialog(
                        title: Text(
                          'warning',
                          style: subHeadingStyle.copyWith(fontSize: 25),
                        ),
                        content:
                            Text('Mark task as completed ?', style: titleStyle),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: body2Style,
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              try {
                                await notifiHelper.cancel(task.id!);
                                await _taskController.deleteTasks(task.id!);
                                // _taskController.getTasks();
                                Get.back();
                                Navigator.pop(context);
                              } catch (e) {
                                Get.snackbar(
                                  'Error',
                                  'task not deleted \n some thing went wrong',
                                  duration: const Duration(seconds: 5),
                                );
                              }
                            },
                            child: Text(
                              'OK',
                              style: body2Style.copyWith(
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      );
                      showDialog(
                          context: context, builder: (ctx) => alertDialog);
                    },
                    clr: Colors.red[300]!,
                  ),
                  Divider(
                    color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                    height: 1,
                  ),
                  _buildBottomSheet(
                    label: 'Cancel',
                    onTap: () {
                      Get.back();
                    },
                    clr: primaryClr,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  _buildBottomSheet(
      {required String label,
      required Function() onTap,
      required Color clr,
      bool isClose = false}) {
    print('screenheight${SizeConfig.screenHeight}');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 65,
        width: SizeConfig.screenWidth * 0.9,
        decoration: BoxDecoration(
          border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : clr),
          borderRadius: BorderRadius.circular(20),
          color: isClose ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style:
                isClose ? titleStyle : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
