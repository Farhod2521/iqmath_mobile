// import 'dart:async';
// import 'dart:io';
// import 'package:my_flutter_template/services/service.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:my_flutter_template/firebase_options.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import '../injector_container.dart';
//
// late AndroidNotificationChannel channel;
// late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// InitializationSettings initializationSettings = const InitializationSettings(
//   android: AndroidInitializationSettings('@mipmap/ic_launcher'),
//   iOS: DarwinInitializationSettings(
//     defaultPresentAlert: true,
//     defaultPresentBadge: true,
//     defaultPresentSound: true,
//     requestAlertPermission: true,
//     requestBadgePermission: true,
//     requestSoundPermission: true,
//   ),
// );
//
// class NotificationService implements Service {
//   Future<void> setupFlutterNotifications() async {
//     if (Platform.isIOS) {
//       await FirebaseMessaging.instance.requestPermission(
//         alert: true,
//         announcement: true,
//         badge: true,
//         carPlay: false,
//         criticalAlert: false,
//         provisional: false,
//         sound: true,
//       );
//     }
//     final token = await FirebaseMessaging.instance.getToken();
//     debugPrint('token: $token');
//     channel = const AndroidNotificationChannel(
//       'high_importance_channel', // id
//       'High Importance Notifications', // title
//       description:
//           'This channel is used for important notifications.', // description
//       importance: Importance.high,
//     );
//     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     await flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }
//
//   void showFlutterNotification(RemoteMessage message) {
//     RemoteNotification? notification = message.notification;
//     flutterLocalNotificationsPlugin.show(
//       notification.hashCode,
//       notification?.title ?? 'empty',
//       notification?.body ?? 'empty',
//       NotificationDetails(
//         android: AndroidNotificationDetails(
//           channel.id,
//           channel.name,
//           channelDescription: channel.description,
//           icon: '@mipmap/ic_launcher',
//           priority: Priority.high,
//           importance: Importance.high,
//           visibility: NotificationVisibility.public,
//         ),
//         iOS: const DarwinNotificationDetails(
//           presentAlert: true,
//           presentBadge: true,
//           presentSound: true,
//         ),
//       ),
//     );
//   }
//
//   void foregroundNotification() {
//     FirebaseMessaging.onMessage.listen(showFlutterNotification);
//
//     ///When tapped
//     flutterLocalNotificationsPlugin.initialize(initializationSettings,
//         onDidReceiveNotificationResponse: (response) async {
//       debugPrint('foreground notification tapped');
//       debugPrint("$response");
//     });
//   }
//
//   void backgroundNotification() {
//     FirebaseMessaging.onBackgroundMessage(
//       _firebaseMessagingBackgroundHandler,
//     );
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       debugPrint('A new onMessageOpenedApp event was published!');
//       // showFlutterNotification(message);
//     });
//   }
//
//   void terminateNotification() async {
//     RemoteMessage? remoteMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (remoteMessage != null) {
//       // showFlutterNotification(remoteMessage);
//     }
//   }
//
//   @override
//   FutureOr<void> dispose() {
//     throw UnimplementedError();
//   }
//
//   @override
//   FutureOr<void> init() async {
//     await setupFlutterNotifications();
//     foregroundNotification();
//     backgroundNotification();
//     terminateNotification();
//   }
// }
//
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   final notificationService = NotificationService();
//   await notificationService.init();
//   // notificationService.showFlutterNotification(message);
// }
