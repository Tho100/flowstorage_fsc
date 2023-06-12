import 'package:flowstorage_fsc/api/notification_api.dart';

class CallNotify {

  Future<void> uploadedNotification({
    required String title,
    required int count
  }) async {

    final setupBodyMessage = 
    count == 1 ? 
    "1 File has been added" : "$count Files has been added";

    await NotificationApi.showNotification(
      title: title,
      body: setupBodyMessage,
      payload: 'h_collin001'
    );
  }

  Future<void> downloadedNotification({
    required String fileName,
  }) async {

    await NotificationApi.showNotification(
      title: "Download Finished",
      body: "$fileName Has been downloaded",
      payload: 'h_collin01'
    );
  }

  Future<void> customNotification({
    required String title,
    required String subMesssage
  }) async {

    await NotificationApi.showNotification(
      title: title,
      body: subMesssage,
      payload: 'h_collin1'
    );
  }

}