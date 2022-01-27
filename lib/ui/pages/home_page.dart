//d
import 'dart:io';

import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/pages/notification_screen.dart';

import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../services/theme_services.dart';
import '../../ui/widgets/task_tile.dart';
import '../size_config.dart';
import '../theme.dart';
import 'add_list_page.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    required this.initialselectedList,
  }) : super(key: key);
  final String initialselectedList;
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final TaskController _taskController = Get.put(TaskController());
  final notifiHelper = NotifyHelper();
  DatePickerController? datePickerController = DatePickerController();
  bool showAllTasks = true;
  GlobalKey key = GlobalKey();
  late File _pickedFile;
  final ImagePicker _picker = ImagePicker();
  final GetStorage _box = GetStorage();
  ImageProvider<Object>? img;
  late String selectedList;
  late List<Tab> tabs;

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

  @override
  void initState() {
    if (_box.read('img') != null)
      img = FileImage(
        File(_box.read('img')),
      );
    selectedList = widget.initialselectedList;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    var y = _taskController.tablesListsNames.keys.toList();
    int z = y.indexWhere((element) => element == selectedList);

    return DefaultTabController(
      length: _taskController.tablesListsNames.length,
      initialIndex: z,
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? darkGreyClr : Colors.white,
        appBar: _appBar(),
        bottomNavigationBar: _bottomAppBar(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Get.off(() => AddTaskPage(
                  listName: selectedList,
                ));
          },
          backgroundColor: context.theme.backgroundColor,
          elevation: 5,
          child: const Icon(
            Icons.add,
            color: primaryClr,
          ),
        ),
        body: TabBarView(
          // controller: _tabController,
          children:
              List.generate(_taskController.tablesListsNames.length, (index) {
            Widget _DateBar = !showAllTasks ? _addDateBar() : Container();
            return RefreshIndicator(
                child: Obx(
                  () {
                    if (index == 0) //new row for localisation
                      selectedList = 'My_Tasks'; //new row for localisation
                    else //new row for localisation
                      selectedList = (tabs[index]).text!;
                    return ListView(
                      children:
                          _taskController.tasksLists[selectedList]!.isEmpty
                              ? [_DateBar, _noTaskMsg()]
                              : ([
                                    _DateBar,
                                    const SizedBox(height: 10),
                                    _showTasks()
                                  ] +
                                  [_showCompletedTasks()]),
                    );
                  },
                ),
                onRefresh: () => _onREfresh(selectedList));
          }),
        ),
      ),
    );
  }

  _generatingList(int isCompleted) {
    RxList<Task> x = _taskController.tasksLists[selectedList]!;
    return List.generate(
      x.length,
      (index) {
        Task task = x[index];
        DateTime formattedDate = DateFormat('yyyy-MM-dd').parse(task
            .date!); //هاد مشان قارن بين التاريخ المحدد وتاريخ التاسك بحيث يصيرو التنين نوع string
        if ((task.isCompleted == isCompleted) &&
            (showAllTasks ||
                formattedDate == _selectedDate || //none repeat condition
                (formattedDate.isBefore(_selectedDate) &&
                    (task.repeat == 'Daily' || //daily condition
                        (task.repeat == 'Weekly' &&
                            DateFormat('EEEE')
                                    .format(DateTime.parse(task.date!)) ==
                                DateFormat('EEEE').format(
                                    _selectedDate)) || //weekly repeat condition
                        (task.repeat == 'Hourly' &&
                            formattedDate.day ==
                                _selectedDate.day //monthly repeat condition
                        ))))) {
          //هون ضفت ال سبتراكت مشان برمجة الريمايند
          // هون وقت استخدم هاد السطر عطا ايرور لان لازم يكون الستارت تايم معمول بشكل معين بالليست تبع التاسك حكا عنو بالفيديو بالوقت9:15

          return AnimationConfiguration.staggeredList(
            position:
                index, //هاد البزسشن بدو انتجر بعبر عن مكان العنصر ضمن الليست
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              horizontalOffset: 300,
              child: FadeInAnimation(
                child: GestureDetector(
                  onTap: () async {
                    await Get.to(() => NotificationScreen(
                          task_: task,
                          listName: selectedList,
                        ));
                  },
                  child: TaskTile(task),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  _showCompletedTasks() {
    return Obx(
      () {
        RxList<Task> x = _taskController.tasksLists[selectedList]!;
        bool y = x.any((element) => element.isCompleted == 1);
        if (y)
          return ExpansionTile(
            collapsedIconColor: primaryClr,
            iconColor: darkGreyClr,
            textColor: darkGreyClr,
            collapsedTextColor: primaryClr,
            title: Text(
              'Completed'.tr,
            ),
            children: [
              SizeConfig.orientation == Orientation.landscape
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _generatingList(1),
                      ),
                    )
                  : Wrap(children: _generatingList(1))
            ],
          );
        else
          return Container();
      },
    );
  }

  Widget _showTasks() {
    return Obx(
      () {
        return SizeConfig.orientation == Orientation.landscape
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: _generatingList(0),
                ),
              )
            : Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                children: _generatingList(0));
      },
    );
  }

  BottomAppBar _bottomAppBar() {
    return BottomAppBar(
      notchMargin: 6.0,
      shape: const CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () => _bottomSheet('menu'),
                icon: Icon(
                  Icons.menu,
                  color: Get.isDarkMode ? Colors.white : darkGreyClr,
                )),
            IconButton(
                onPressed: () => _bottomSheet('more_vert'),
                icon: const Icon(Icons.more_vert))
          ],
        ),
      ),
      color: Get.isDarkMode ? Colors.grey[900] : Colors.white,
      elevation: 5,
    );
  }

  AppBar _appBar() {
    final listNames = _taskController.tablesListsNames.keys.toList();
    tabs = List.generate(
      listNames.length,
      (index) {
        if (index == 0) {
          //new row for localisation
          return Tab(
            //new row for localisation
            text: 'My_Tasks'.tr,
          );
        } //new row for localisation
        return Tab(
          text: listNames[index],
        );
      },
    );
    return AppBar(
      bottom: TabBar(
        isScrollable: true, //tabs.length > 3 ? true : false,
        indicatorColor: primaryClr,
        indicatorSize: TabBarIndicatorSize.label,
        labelColor: primaryClr,
        unselectedLabelColor: subTitleStyle.color,
        tabs: tabs,
      ),
      leading: Padding(
        padding: EdgeInsets.only(
            left: Get.locale.toString() == 'en' ? 15 : 0,
            right: Get.locale.toString() == 'ar' ? 15 : 0),
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
                datePickerController!.animateToDate(DateTime.now());
              });
            },
            icon: Icon(
              Icons.restart_alt_sharp,
              size: 18,
              color: Get.isDarkMode ? Colors.white : darkGreyClr,
            ),
          ),
        IconButton(
          onPressed: () async {
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
          tooltip: 'Filter options',
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
                      'ShowAllTasks'.tr,
                      style: bodyStyle,
                    ),
                    CircleAvatar(
                      radius: 5,
                      backgroundColor: showAllTasks ? primaryClr : Colors.grey,
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
                    'FilterByDate'.tr,
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: !showAllTasks ? primaryClr : Colors.grey,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              height: 40,
              onTap: () {
                Get.updateLocale(const Locale('ar'));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ar'.tr,
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: Get.locale.toString() == 'ar'
                        ? primaryClr
                        : Colors.grey,
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              height: 40,
              onTap: () {
                Get.updateLocale(const Locale('en'));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'En'.tr,
                    textAlign: TextAlign.center,
                    style: bodyStyle,
                  ),
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: Get.locale.toString() == 'en'
                        ? primaryClr
                        : Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _onREfresh(listName) async {
    await TaskController().getTasks(listName: listName);
  }

  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(
          top: 6,
          left: Get.locale.toString() == 'en' ? 20 : 0,
          right: Get.locale.toString() == 'en' ? 0 : 20),
      child: DatePicker(
        DateTime.now(),
        locale: Get.locale.toString(),
        controller: datePickerController,
        width: 70,
        height: 100,
        initialSelectedDate: _selectedDate,
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
          });
        },
      ),
    );
  }

  Widget _noTaskMsg() {
    return Center(
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(microseconds: 2000),
            child: RefreshIndicator(
              onRefresh: () => _onREfresh(selectedList),
              child: SingleChildScrollView(
                child: Column(
                  // alignment: WrapAlignment.center,
                  // crossAxisAlignment: WrapCrossAlignment.center,
                  //direction: Axis.vertical,
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
                          horizontal: 10, vertical: 10),
                      child: Text(
                        'You-do-not-have-any-tasks-yet!'.tr,
                        style: SizeConfig.orientation == Orientation.portrait
                            ? subHeadingStyle.copyWith(
                                fontSize: SizeConfig.screenWidth * 0.06)
                            : subHeadingStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'Add-new-tasks-to-make-your-days-productive'.tr,
                        style: SizeConfig.orientation == Orientation.portrait
                            ? subTitleStyle.copyWith(
                                fontSize: SizeConfig.screenWidth * 0.045)
                            : subTitleStyle,
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
      ),
    );
  }

  _bottomSheet(String name) {
    if (name == 'menu') {
      Get.bottomSheet(
        Container(
          width: SizeConfig.screenWidth,
          color: Get.isDarkMode ? context.theme.backgroundColor : Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: TextButton.icon(
                    style: ButtonStyle(
                      overlayColor: MaterialStateColor.resolveWith(
                          (states) => Colors.grey.withOpacity(0.15)),
                    ),
                    onPressed: () async {
                      Get.offAll(() => AddTaskList(
                            previousListName: selectedList,
                          ));
                    },
                    icon: const Icon(
                      Icons.add,
                      color: primaryClr,
                    ),
                    label: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Create-new-list'.tr,
                        style:
                            subTitleStyle.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      bool emptyCondition = _taskController.tasksLists[selectedList]!.isEmpty;
      bool selecteListCondition = (selectedList == 'My_Tasks');
      bool completedCondition = _taskController.tasksLists[selectedList]!
          .any((element) => element.isCompleted == 1);
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.only(top: 4),
          width: SizeConfig.screenWidth,
          color: Get.isDarkMode ? darkGreyClr : Colors.white,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: Get.locale.toString() == 'en'
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: selecteListCondition
                      ? null
                      : () async {
                          var alertDialog = AlertDialog(
                            title: Text(
                              'Warning'.tr,
                              style: subHeadingStyle.copyWith(
                                  fontSize: 25, color: primaryClr),
                            ),
                            content: Text('Deletelist?'.tr, style: titleStyle),
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
                                    final listOfId = await _taskController
                                        .deleteAllTasksListNotifications(
                                            listName: selectedList);
                                    await _taskController
                                        .deleteLsit(selectedList);
                                    Get.offAll(() => const HomePage(
                                          initialselectedList: 'My_Tasks',
                                        ));
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error'.tr,
                                      'some thing went wrong'.tr,
                                      // duration: const Duration(seconds: 5),
                                    );
                                  }
                                },
                                child: Text(
                                  'OK'.tr,
                                  style: body2Style.copyWith(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          );
                          showDialog(
                              context: context, builder: (ctx) => alertDialog);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: !selecteListCondition
                        ? Text(
                            'Deletelist'.tr,
                            style: subTitleStyle,
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                'Deletelist'.tr,
                                style:
                                    subTitleStyle.copyWith(color: Colors.grey),
                              ),
                              Text(
                                'Default-list-can\'t-be-deleted'.tr,
                                style: subTitleStyle.copyWith(
                                    color: Colors.grey, fontSize: 12),
                              )
                            ],
                          ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.withOpacity(0.15)),
                  ),
                ),
                const Divider(),
                TextButton(
                  onPressed: emptyCondition
                      ? null
                      : () async {
                          var alertDialog = AlertDialog(
                            title: Text(
                              'Warning'.tr,
                              style: subHeadingStyle.copyWith(
                                  fontSize: 25, color: primaryClr),
                            ),
                            content: Text('Delete-all-list-tasks?'.tr,
                                style: titleStyle),
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
                                    final listOfId = await _taskController
                                        .deleteAllTasksListNotifications(
                                            listName: selectedList);
                                    await notifiHelper
                                        .cancelAllListNotifications(listOfId);
                                    await _taskController
                                        .deleteAllTasks(selectedList);
                                    await _taskController.getTasks(
                                        listName: selectedList);
                                    Get.back();
                                    Get.back();
                                  } catch (e) {
                                    Get.snackbar(
                                      'Error'.tr,
                                      'some thing went wrong'.tr,
                                      // duration: const Duration(seconds: 5),
                                    );
                                  }
                                },
                                child: Text(
                                  'OK'.tr,
                                  style: body2Style.copyWith(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          );
                          showDialog(
                              context: context, builder: (ctx) => alertDialog);
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: Text(
                      'Delete-all-list-tasks'.tr,
                      style: emptyCondition
                          ? subTitleStyle.copyWith(color: Colors.grey)
                          : subTitleStyle,
                    ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.withOpacity(0.15)),
                  ),
                ),
                TextButton(
                  onPressed: completedCondition
                      ? () async {
                          var alertDialog = AlertDialog(
                            title: Text(
                              'Warning'.tr,
                              style: subHeadingStyle.copyWith(
                                  fontSize: 25, color: primaryClr),
                            ),
                            content: Text('Delete-Completed-tasks?'.tr,
                                style: titleStyle),
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
                                    final listOfId = await _taskController
                                        .deleteAllTasksListNotifications(
                                            listName: selectedList,
                                            isCompleted: true);
                                    await notifiHelper
                                        .cancelAllListNotifications(listOfId);
                                    await _taskController
                                        .deleteCompletedTasks(selectedList);
                                    await _taskController.getTasks(
                                        listName: selectedList);
                                    Get.back();
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
                                  style: body2Style.copyWith(
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          );
                          showDialog(
                              context: context, builder: (ctx) => alertDialog);
                        }
                      : null,
                  child: Container(
                    //   alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    width: double.infinity,
                    child: Text(
                      'Delete-Completed-tasks'.tr,
                      style: completedCondition
                          ? subTitleStyle
                          : subTitleStyle.copyWith(color: Colors.grey),
                    ),
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateColor.resolveWith(
                        (states) => Colors.grey.withOpacity(0.15)),
                  ),
                ),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
