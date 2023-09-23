import 'package:first_priority_app/meetings/controller/meeting_controller.dart';
import 'package:first_priority_app/meetings/meeting_create.dart';
import 'package:first_priority_app/meetings/meeting_preview.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:first_priority_app/widgets/fab_mixin.dart';
import 'package:first_priority_app/widgets/policy_builder.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MeetingScreen extends StatefulWidget with FabMixin {
  @override
  _MeetingScreenState createState() => _MeetingScreenState();

  @override
  Widget buildFab(BuildContext context) {
    return PolicyBuilder(
      policy: Policy.manageMeetings,
      builder: (context, valid) {
        if (!valid) {
          return Container();
        }

        return FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Get.to(() => MeetingCreate());
          },
        );
      },
    );
  }
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  Widget build(BuildContext context) {
    return GetX<MeetingController>(
      builder: (controller) {
        return FutureBuilder<List<Meeting>>(
          future: controller.get(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.data.isEmpty) {
              return Center(
                child: TitleText("No Upcoming Meetings"),
              );
            }

            return Wrap(
              runSpacing: 4,
              children: List.generate(snapshot.data.length, (index) {
                return MeetingPreview(
                  meeting: snapshot.data[index],
                );
              }),
            );
          },
        );
      },
    );
  }
}
