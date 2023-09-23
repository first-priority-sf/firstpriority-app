import 'package:confirm_dialog/confirm_dialog.dart';
import 'package:first_priority_app/controllers/message.dart';
import 'package:first_priority_app/meetings/controller/meeting_controller.dart';
import 'package:first_priority_app/meetings/meeting_create.dart';
import 'package:first_priority_app/meetings/order/order_screen.dart';
import 'package:first_priority_app/meetings/report/report_screen.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:first_priority_app/models/meeting_role.dart';
import 'package:first_priority_app/widgets/dialogs/select_dialog.dart';
import 'package:first_priority_app/widgets/loading_dialog.dart';
import 'package:first_priority_app/widgets/pdf_viewer_screen.dart';
import 'package:first_priority_app/widgets/policy_builder.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:first_priority_app/widgets/text/subtitle_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetails extends StatefulWidget {
  final Meeting meeting;

  MeetingDetails({Key key, @required this.meeting}) : super(key: key);

  @override
  _MeetingDetailsState createState() => _MeetingDetailsState();
}

class _MeetingDetailsState extends State<MeetingDetails> {
  final MeetingController _meetingController = Get.find<MeetingController>();
  final MessageController _messageController = Get.find<MessageController>();

  List<String> orderedMeetingRoleIds = [];

  @override
  void initState() {
    super.initState();
    orderedMeetingRoleIds = widget.meeting.roles.keys.toList()
      ..sort(
        (a, b) =>
            MeetingRole.roles[a].order.compareTo(MeetingRole.roles[b].order),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Meeting meeting = widget.meeting;

    return Scaffold(
      appBar: AppBar(
        title: Text("Meeting Details"),
      ),
      floatingActionButton: PolicyBuilder(
        policy: Policy.manageMeetings,
        builder: (context, valid) {
          if (!valid) return Container();
          if (meeting.time.toLocal().isBefore(DateTime.now()))
            return Container();

          return _buildSpeedDial(context);
        },
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  TitleText("${widget.meeting.week} Week"),
                  SizedBox(
                    width: 8,
                  ),
                  Icon(
                    DateTime.now().isAfter(meeting.time)
                        ? Icons.check
                        : Icons.calendar_today,
                  )
                ],
              ),
              SubtitleText(
                'Cycle: ${widget.meeting.cycle}',
              ),
              SizedBox(
                height: 8,
              ),
              SubtitleText(
                Jiffy(widget.meeting.time).format("EEEE, MMMM do"),
              ),
              SubtitleText(
                '${Jiffy(widget.meeting.time).format("h:mma")} • ${widget.meeting.room}',
              ),
              PolicyBuilder(
                policy: Policy.manageMeetings,
                builder: (context, valid) {
                  if (!valid) return Container();
                  if (DateTime.now().isAfter(meeting.time.toLocal()))
                    return _buildReportButton();

                  if (meeting.week == "Invite")
                    return _buildOrderButton(meeting);

                  return Container();
                },
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: ElevatedButton(
                  onPressed: () async {
                    await launch(meeting.videoUrl);
                  },
                  child: Text("Video Summary"),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 5),
                child: ElevatedButton(
                  onPressed: () async {
                    Get.to(
                      () => PdfViewerScreen(
                        title: "Discussion Guide",
                        url: meeting.pdfUrl,
                      ),
                    );
                  },
                  child: Text("Discussion Guide"),
                ),
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: Divider(),
              ),
              TitleText("Roles"),
              if (meeting.roles.isNotEmpty)
                ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: orderedMeetingRoleIds.length,
                  itemBuilder: (context, index) {
                    var key = orderedMeetingRoleIds[index];
                    return ListTile(
                      title: Text(MeetingRole.roles[key].name),
                      subtitle: Text(
                        meeting.roles[key].map((e) => e.name).join(', '),
                      ),
                    );
                  },
                  separatorBuilder: (contxt, _) => const Divider(),
                ),
              if (meeting.roles.isEmpty)
                Container(
                  margin: EdgeInsets.only(top: 50),
                  child: Center(
                    child: SubtitleText(
                      "No Meeting Roles",
                      fontSize: 24,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  Container _buildOrderButton(Meeting meeting) {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: ElevatedButton(
        onPressed: () async {
          Get.to(() => OrderScreen(meeting: meeting));
        },
        child: Text("Invite Order"),
      ),
    );
  }

  Widget _buildSpeedDial(BuildContext context) {
    final labelStyle =
        TextStyle(color: Theme.of(context).textTheme.headline1.color);
    final labelBackground = Theme.of(context).cardColor;
    return SpeedDial(
      foregroundColor:
          Theme.of(context).floatingActionButtonTheme.foregroundColor,
      backgroundColor:
          Theme.of(context).floatingActionButtonTheme.backgroundColor,
      elevation: Theme.of(context).floatingActionButtonTheme.elevation,
      icon: Icons.settings,
      activeIcon: Icons.close,
      overlayColor: Colors.black,
      overlayOpacity: 0,
      tooltip: 'Options',
      heroTag: 'options-hero-tag',
      children: [
        SpeedDialChild(
          label: "Notifications",
          labelStyle: labelStyle,
          labelBackgroundColor: labelBackground,
          child: Icon(Icons.notifications_active),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onTap: _buildSpeedDialNotificationsDialog,
        ),
        SpeedDialChild(
          label: "Edit",
          labelStyle: labelStyle,
          labelBackgroundColor: labelBackground,
          child: Icon(Icons.edit),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onTap: () {
            Get.off(
              () => MeetingCreate(
                meeting: widget.meeting,
              ),
            );
          },
        ),
        SpeedDialChild(
          label: "Cancel",
          labelStyle: labelStyle,
          labelBackgroundColor: labelBackground,
          child: Icon(Icons.cancel),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onTap: _buildSpeedDialCancelDialog,
        ),
        SpeedDialChild(
          label: "Order",
          labelStyle: labelStyle,
          labelBackgroundColor: labelBackground,
          child: Icon(Icons.receipt),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          onTap: () async {
            Get.to(() => OrderScreen(meeting: widget.meeting));
          },
        ),
      ],
    );
  }

  Future<void> _buildSpeedDialCancelDialog() async {
    if (await confirm(
      context,
      title: Text('Are you sure?'),
      content: Text('Would you like to cancel this meeting?'),
      textOK: Text('Yes'),
      textCancel: Text('No'),
    )) {
      LoadingDialog.show(
        context: context,
        future: () async {
          await _meetingController.cancel(widget.meeting);
        },
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _buildSpeedDialNotificationsDialog() async {
    final messages = await _messageController.get();

    await showDialog(
      context: context,
      builder: (context) {
        return SelectDialog(
          title: "Notifications",
          itemCount: messages.length,
          itemBuilder: (BuildContext context, int index) {
            final message = messages[index];
            return ListTile(
              title: Text(message.name),
              onTap: () async {
                if (await confirm(
                  context,
                  title: Text("Are you sure?"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: message.title == null || message.body == null
                        ? [
                            Text(
                              "Are you sure you want to send this notifcation?",
                            )
                          ]
                        : [
                            Container(
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text(
                                "Preview",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text("${message.title}\n${message.body}")
                          ],
                  ),
                  textOK: Text("Send"),
                  textCancel: Text("Cancel"),
                )) {
                  await LoadingDialog.show(
                    context: context,
                    future: () async {
                      _messageController.send(
                        widget.meeting.id,
                        messages[index].id,
                      );
                    },
                  );
                }
                Navigator.of(context).pop();
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReportButton() {
    return FutureBuilder<bool>(
      future: _meetingController.hasReport(widget.meeting.time),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        if (snapshot.data ?? false) {
          return Container();
        }

        return Container(
          margin: EdgeInsets.only(top: 5),
          child: ElevatedButton(
            onPressed: () {
              Get.to(
                () => ReportScreen(meeting: widget.meeting),
              );
            },
            child: Text("Submit Report"),
          ),
        );
      },
    );
  }
}
