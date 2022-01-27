//d
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:to_do_app/db/db_helper.dart';
import 'package:to_do_app/ui/pages/splash_screen.dart';
import 'services/notification_services.dart';
import 'package:to_do_app/services/theme_services.dart';
import 'package:to_do_app/ui/theme.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //هون ضروري كتير انو نحط اقواس لانو اذا ما حطيت بصير خطأ بالتهيئة
  await NotifyHelper().initializeNotification();
  NotifyHelper().requestIOSPermissions();
  await DBHelper.initDb();
  await GetStorage.init();

  runApp(
    const MyApp(),
  );
}

class Messages extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'My_Tasks': 'My_Tasks',
          'ShowAllTasks': 'Show All Tasks',
          'FilterByDate': 'Filter By Date',
          'En': 'En',
          'Ar': 'Ar',
          'Deletelist': 'Delete list',
          'Deletelist?': 'Deletelist?',
          'Default-list-can\'t-be-deleted': 'Default list can\'t be deleted',
          'Delete-all-list-tasks': 'Delete all list tasks',
          'Delete-all-list-tasks?': 'Delete all list tasks ?',
          'Delete-Completed-tasks': 'Delete Completed tasks',
          'Delete-Completed-tasks?': 'Delete Completed tasks ?',
          'You-do-not-have-any-tasks-yet!': 'You do not have any tasks yet!',
          'Add-new-tasks-to-make-your-days-productive':
              'Add new tasks to make your days productive',
          'Create-new-list': 'Create new list',
          'Done': 'Done',
          'Title': 'Title',
          'Note': 'Note',
          'Date': 'Date',
          'StartTime': 'StartTime',
          'EndTime': 'EndTime',
          'Remind': 'Remind',
          'Repeat': 'Repeat',
          'Required': '(Required)',
          'Color': 'Color',
          'AddTask': 'Add Task',
          'None': 'None',
          'CreateTask': 'Create Task',
          'EnterTitleHere': 'Enter title here',
          'EnterNoteHere': 'Enter Note Here',
          'MinutesEarly': 'minutes early',
          'Hourly': 'Hourly',
          'Daily': 'Daily',
          'Weekly': 'Weekly',
          'RemindBefore': 'Remind before',
          'Minutes': ' minutes',
          'Warning': 'Warning',
          'DeleteTheTask?': 'Delete the task ?',
          'DeleteAllTheTasks ?': 'Delete all the tasks',
          'OK': 'OK',
          'Enter-list-name': 'Enter list name',
          'Cancel': 'Cancel',
          'Completed': 'Completed',
          'required': 'required',
          'All fields are required': 'All fields are required',
          'Error': 'Error',
          'Name Mustn\'t contains more then 30 charactar ':
              'Name Mustn\'t contains more then 30 charactar ',
          'some thing went wrong': 'some thing went wrong',
          'ToDo': 'To Do'
        },
        'ar': {
          'My_Tasks': 'مهامي',
          'ShowAllTasks': 'إظهار كل المهام',
          'FilterByDate': 'تصفية بالتاريخ',
          'En': 'إنجليزي',
          'Ar': 'عربي',
          'Deletelist': 'حذف القائمة ',
          'Deletelist?': 'حذف القائمة ؟ ',
          'Default-list-can\'t-be-deleted': 'القائمة الإفتراضية لا يمكن حذفها',
          'Delete-all-list-tasks': 'حذف كل المهام في القائمة',
          'Delete-all-list-tasks?': 'حذف كل المهام في القائمة ؟',
          'Delete-Completed-tasks': 'حذف المهام المكتملة',
          'Delete-Completed-tasks?': 'حذف المهام المكتملة ؟',
          'You-do-not-have-any-tasks-yet!': 'ليس لديك أي مهام بعد! ',
          'Add-new-tasks-to-make-your-days-productive':
              'أضف مهاما جديدة لجعل أيامك مثمرة',
          'Create-new-list': 'إنشاء قائمة جديدة',
          'Done': 'تم',
          'Enter-list-name': 'أدخل إسم القائمة',
          'Title': 'العنوان',
          'Note': 'ملاحظة',
          'Date': 'التاريخ',
          'StartTime': 'وقت البداية',
          'EndTime': 'وقت النهاية',
          'Remind': 'تذكير',
          'Repeat': 'تكرار',
          'Required': '(مطلوب)',
          'Color': 'اللون',
          'AddTask': 'إضافة مهمة',
          'CreateTask': 'إنشاء مهمة',
          'None': 'لا شيئ',
          'EnterTitleHere': 'أدخل العنوان هنا',
          'EnterNoteHere': 'أدخل الملاحظة هنا',
          'MinutesEarly': 'قبل دقائق',
          'Hourly': 'كل ساعة',
          'Daily': 'كل يوم',
          'Weekly': 'كل أسبوع',
          'RemindBefore': 'تذكير قبل',
          'Minutes': ' دقائق',
          'Warning': 'تحذير',
          'DeleteTheTask?': 'حذف المهمة ؟',
          'DeleteAllTheTasks ?': 'حذف جميع المهام ؟',
          'OK': 'موافق',
          'Cancel': 'إلغاء',
          'Completed': 'مكتمل',
          'required': 'مطلوب',
          'All fields are required': ' كل الحقول مطلوبة ',
          'Error': 'خطأ',
          'Name Mustn\'t contains more then 30 charactar ':
              'الاسم يجب أن لا يحتوي على أكثر من 30 حرف',
          'some thing went wrong': 'حدث خطأ ما ',
          'ToDo': 'للقيام  بها'
        }
      };
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      translations: Messages(), // your translations
      locale:
          const Locale('en'), // translations will be displayed in that locale
      fallbackLocale: const Locale(
          'en'), // specify the fallback locale in case an invalid locale is selected.

      theme: Themes.light,
      darkTheme: Themes.dark,
      themeMode: ThemeServices().theme,
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
