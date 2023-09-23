import 'package:first_priority_app/controllers/notification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:first_priority_app/models/notification.dart' as model;

class NotificationsScreen extends StatelessWidget {
  final _notificationsStore = Get.find<NotificationStore>();

  NotificationsScreen({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: FutureBuilder<List<model.Notification>>(
        future: _notificationsStore.list(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center();
          }

          return ListView(
            children: ListTile.divideTiles(
              context: context,
              tiles: [
                ...List.generate(snapshot.data.length, (index) {
                  return ListTile(
                    title: Text(snapshot.data[index].title),
                    subtitle: Text(snapshot.data[index].body),
                  );
                }),
              ],
            ).toList(),
          );
        },
      ),
    );
  }
}
