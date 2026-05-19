//import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class LocalNotificationService {
  // late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  //
  // LocalNotificationService() {
  //   flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  //   const AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('notification_icon'); // Ensure you have the icon in the drawable folder
  //
  //   final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
  //     requestAlertPermission: true,
  //     requestBadgePermission: true,
  //     requestSoundPermission: true,
  //     //onDidReceiveLocalNotification: (id, title, body, payload) => handleNotificationClick(payload),
  //   );
  //   InitializationSettings initializationSettings = InitializationSettings(
  //     android: initializationSettingsAndroid,
  //     iOS: initializationSettingsIOS,
  //   );
  //   flutterLocalNotificationsPlugin.initialize(
  //     initializationSettings,
  //     onDidReceiveNotificationResponse: (NotificationResponse response) {
  //       handleNotificationClick(response.payload);
  //     },
  //     onDidReceiveBackgroundNotificationResponse: backgroundNotificationHandler,
  //   );
  //
  //   _configureLocalTimeZone();
  //   // tz.initializeTimeZones(); // Initialize time zone database
  // }
  //
  // void requestPermissions() {
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  //   flutterLocalNotificationsPlugin
  //       .resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()
  //       ?.requestPermissions(
  //         alert: true,
  //         badge: true,
  //         sound: true,
  //       );
  // }
  //
  // void requestExactAlarmPermission() async {
  //   if (await Permission.scheduleExactAlarm.isDenied) {
  //     await Permission.scheduleExactAlarm.request();
  //   }
  // }
  //
  // Future<void> _configureLocalTimeZone() async {
  //   tz.initializeTimeZones();
  //   tz.setLocalLocation(
  //     tz.getLocation('Africa/Cairo'),
  //   );
  // }
  //
  // void scheduleDailyNotification() async {
  //   debugPrint('called scheduleDailyNotification');
  //   requestExactAlarmPermission();
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'daily notification channel id',
  //     'daily notification channel name',
  //     channelDescription: 'Daily notification description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     color: primary,
  //     icon: 'notification_icon',
  //     showWhen: false,
  //   );
  //   const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: androidPlatformChannelSpecifics,
  //     iOS: iOSPlatformChannelSpecifics,
  //   );
  //
  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     Loc.updateContacts(),
  //     Loc.helpYourFriends(),
  //     payload: 'update_contacts_sheet',
  //     _nextInstanceOfNinePM(),
  //     platformChannelSpecifics,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     matchDateTimeComponents: DateTimeComponents.time, // Ensures it repeats daily
  //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }
  //
  // tz.TZDateTime _nextInstanceOfNinePM() {
  //   final tz.TZDateTime now = tz.TZDateTime.now(
  //     tz.local,
  //   );
  //   debugPrint('now: $now');
  //   tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 21);
  //   if (scheduledDate.isBefore(now)) {
  //     debugPrint('isBefore');
  //     scheduledDate = scheduledDate.add(
  //       const Duration(days: 1),
  //     );
  //   }
  //   debugPrint('scheduledDate: $scheduledDate');
  //   return scheduledDate;
  // }
  //
  // void sendImmediateNotification() async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'immediate notification channel id',
  //     'immediate notification channel name',
  //     icon: 'notification_icon',
  //     channelDescription: 'Immediate notification description',
  //     color: primary,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     showWhen: false,
  //   );
  //   const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
  //     presentAlert: true,
  //     presentBadge: true,
  //     presentSound: true,
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  //
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Immediate Notification Test',
  //     'This is an immediate notification Test Body',
  //     payload: 'update_contacts_sheet',
  //     platformChannelSpecifics,
  //   );
  // }
  //
  // static void handleNotificationClick(String? payload) {
  //   if (payload == 'update_contacts_sheet') {
  //     // Nav.updateUnCompleteContactScreen(
  //     //   Nav.mainNavKey.currentState!.context,
  //     // );
  //   }
  // }
  //
  // static void backgroundNotificationHandler(NotificationResponse response) {
  //   if (response.payload == 'update_contacts_sheet') {
  //     // Nav.updateUnCompleteContactScreen(
  //     //   Nav.mainNavKey.currentState!.context,
  //     // );
  //   }
  // }
}
