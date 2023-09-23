import 'package:first_priority_app/controllers/notification.dart';
import 'package:first_priority_app/more/notifications_screen.dart';
import 'package:first_priority_app/widgets/text/subtitle_text.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:first_priority_app/models/notification.dart' as model;
import 'package:jiffy/jiffy.dart';

class NotificationsCard extends StatelessWidget {
  NotificationsCard({Key key}) : super(key: key);

  final _notificationStore = Get.find<NotificationStore>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<model.Notification>(
        future: _notificationStore.last(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }

          return SizedBox(
            width: double.infinity,
            child: Card(
              margin: EdgeInsets.all(8),
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => NotificationsScreen());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleText("Notifications"),
                        SubtitleText(
                          Jiffy(
                            DateTime.fromMillisecondsSinceEpoch(
                              snapshot.data.time.millisecondsSinceEpoch,
                            ),
                          ).format("EEEE, MMMM do h:mma"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        ListTile(
                          title: Text(snapshot.data.title),
                          subtitle: Text(snapshot.data.body),
                        )
                      ],
                    ),
                  )),
            ),
          );
        });
  }
}
