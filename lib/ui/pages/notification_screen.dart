import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:to_do_app/controllers/task_controller.dart';
import 'package:to_do_app/services/notification_services.dart';
import 'package:to_do_app/ui/theme.dart';

class NotificationScreen extends StatefulWidget {
  final String payload;
  const NotificationScreen({
    Key? key,
    required this.payload,
  }) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TaskController _taskController = Get.put(TaskController());
  final notifiHelper = NotifyHelper();
  String _payload = '';
  @override
  void initState() {
    _payload = widget.payload;
    super.initState();
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
                int.parse(_payload.split('|')[3]),
                int.parse(_payload.split('|')[4]));
            Get.back();
          },
          child: Text(
            int.parse(_payload.split('|')[4]) == 0
                ? 'Mark completed'
                : 'Mark uncompleted',
            style: bodyStyle,
          ),
        ),
      ),
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
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
                  'warning',
                  style: subHeadingStyle.copyWith(fontSize: 25),
                ),
                content: Text('Mark task as completed ?', style: titleStyle),
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
                        await notifiHelper
                            .cancel(int.parse(_payload.split('|')[3]));
                        await _taskController
                            .deleteTasks(int.parse(_payload.split('|')[3]));
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
        /*centerTitle: true,
        title: Text(
          _payload.toString().split('|')[0],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),*/
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'Hello Hassan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You have a new reminder',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w300,
                color: Get.isDarkMode ? Colors.grey[100] : darkGreyClr,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                margin: const EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  color: primaryClr,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.text_format,
                          size: 30,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Title',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _payload.split('|')[0],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Icon(
                          Icons.description,
                          size: 30,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Description',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _payload.split('|')[1],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: const [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 35,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'Date',
                          style: TextStyle(color: Colors.white, fontSize: 30),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _payload.split('|')[2],
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                )),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      /*floatingActionButton: FloatingActionButton(
        backgroundColor: context.theme.backgroundColor,
        onPressed: () {
          _taskController.markTaskCompleted(int.parse(_payload.split('|')[3]));
          Get.back();
        },
        child: const Icon(
          Icons.done,
          color: darkGreyClr,
        ),
      ),*/
    );
  }
}
