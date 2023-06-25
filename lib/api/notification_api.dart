import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationApi {

  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future _notificationDetails() async {

    return const NotificationDetails(
      android: AndroidNotificationDetails(
        '001',
        'notify_main',
        channelDescription: 'Alert user if a task is finished',
        importance: Importance.max,
        icon: "@mipmap/ic_launcher",
        playSound: false,
        enableVibration: false,
      ),
    );
  }

  static Future showNotification({
    int id = 0,
    String? title,
    String? body,
    String? payload
  }) async => _notifications.show(
    id, title, body, await _notificationDetails(),payload: payload);
    
  static Future stopNotification(int id) async {
    await _notifications.cancel(id);
  }
}