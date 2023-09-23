import 'package:first_priority_app/meetings/meeting_details.dart';
import 'package:first_priority_app/models/meeting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MeetingPreview extends StatelessWidget {
  final Meeting meeting;

  const MeetingPreview({Key key, @required this.meeting}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(
          () => MeetingDetails(
            meeting: meeting,
          ),
        );
      },
      child: ListTile(
        title: Text(
          'Weekly Meeting: ${meeting.week}',
          style: Theme.of(context).textTheme.headline3,
        ),
        subtitle: Text(
          '${meeting.school}: ${meeting.room}',
          style: Theme.of(context).textTheme.headline4,
        ),
        trailing: Icon(
          DateTime.now().isAfter(meeting.time)
              ? Icons.check
              : Icons.calendar_today,
        ),
        leading: InkWell(
          child: Container(
            // margin: EdgeInsets.only(left: 10),
            alignment: Alignment.centerRight,
            height: 60,
            width: 70,
            child: Material(
              borderRadius: BorderRadius.circular(4),
              shadowColor: Colors.black12,
              color: Theme.of(context).secondaryHeaderColor,
              elevation: 5,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('MMM')
                          .format(meeting.time ?? DateTime.now())
                          .toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      DateFormat('d').format(meeting.time ?? DateTime.now()),
                      style: Theme.of(context)
                          .textTheme
                          .bodyText2
                          .copyWith(fontWeight: FontWeight.w700, fontSize: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
