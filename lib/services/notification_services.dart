//d
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:to_do_app/controllers/task_controller.dart';
import '/models/task.dart';
import '/ui/pages/notification_screen.dart';

class NotifyHelper {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TaskController _taskController = Get.put(TaskController());
  String selectedNotificationPayload = ''; //NEWWWWWWWWW

  final BehaviorSubject<String> selectNotificationSubject =
      BehaviorSubject<String>(); //NEWWWWWWWWWW
  initializeNotification() async {
    tz.initializeTimeZones();
    _configureSelectNotificationSubject(); //NEWWWWWW
    await _configureLocalTimeZone(); //NEWWWWWW
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');

    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String? payload) async {
        if (payload != null) {}
        selectNotificationSubject
            .add(payload!); //selectNotificationهون انا مستخدم غير تابع يلي هو
      },
    );
  }

  cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  cancelAllListNotifications(List<int> x) async {
    for (int i in x) {
      await cancel(i);
    }
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  scheduledNotification(
      int hour, int minutes, Task task, String listName) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      task.id!,
      task.title,
      task.note,
      _nextInstanceOfTenAM(hour, minutes, task),
      // هون فصل هاد المتغير بتابع لحال مشان يعالج اختلاف التايم زون من بلد لبلد
      const NotificationDetails(
        android: AndroidNotificationDetails(
            'your channel id', 'your channel name',
            channelDescription: 'your channel description'),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload:
          '${task.title}|${task.note}|${task.startTime}|${task.id}|${task.isCompleted}|$listName|${task.date}|${task.repeat}|${task.remind}|${task.color}|${task.endTime}|',
    );

    if (task.repeat != 'None') {
      var taskDate = DateTime(
        int.parse(task.date!.split('-')[0]),
        int.parse(task.date!.split('-')[1]),
        int.parse(task.date!.split('-')[2]),
        hour,
        minutes,
      );
      RepeatInterval ri() {
        if (task.repeat == 'Daily') {
          return RepeatInterval.daily;
        } else if (task.repeat == 'Weekly') {
          return RepeatInterval.weekly;
        } else {
          return RepeatInterval.hourly;
        }
      }

      RepeatInterval interval = ri();

      var timerDuraion = taskDate.difference(DateTime.now());
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'repeating channel id', 'repeating channel name',
              channelDescription: 'repeating description');
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);
      Timer(
        timerDuraion,
        () async => await flutterLocalNotificationsPlugin.periodicallyShow(
          task.id!,
          task.title,
          task.note,
          interval,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          payload:
              '${task.title}|${task.note}|${task.startTime}|${task.id}|${task.isCompleted}|$listName|${task.date}|${task.repeat}|${task.remind}|',
        ),
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTenAM(int hour, int minutes, Task task) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(DateTime.parse(task.date!), tz.local)
            .add(Duration(hours: hour, minutes: minutes));

    return scheduledDate;
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureSelectNotificationSubject() {
    //هاد التابع مشان وقت اكبس عالاشعار يعمل شي معين وهون عم ينقلني على صفحةال NotificationScreen
    selectNotificationSubject.stream.listen((String payload) async {
      // scheduledNotification هو نفسو يلي بعتو بتابع ال payload
      await _taskController.getAllTasks();
      Task task = Task(
          title: payload.split('|')[0],
          note: payload.split('|')[1],
          startTime: payload.split('|')[2],
          id: int.parse(payload.split('|')[3]),
          isCompleted: int.parse(payload.split('|')[4]),
          date: payload.split('|')[6],
          repeat: payload.split('|')[7],
          remind: int.parse(payload.split('|')[8]),
          color: int.parse(payload.split('|')[9]),
          endTime: payload.split('|')[10]);
      await Get.to(() => NotificationScreen(
            // payload: payload,
            task_: task, listName: payload.split('|')[5],
            //  task: task,
            //  listName: payload.split('|')[5],
          ));
    });
  } //

//Older IOS
  Future onDidReceiveLocalNotification(
      //هاد التابع قديم وماعاد مستخدم ولا ضروري ابدا
      int id,
      String? title,
      String? body,
      String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    Get.dialog(Text(body!));
  }

  displayNotification({required String title, required String body}) async {
    //scheduledNotification هاد التابع بلا طعمة لانو مكرر بقلب ال
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'your channel id', 'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high);
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Default_Sound',
    );
  }
}
