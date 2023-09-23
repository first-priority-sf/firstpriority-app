import 'package:first_priority_app/home/homeScreen/components/notifications_card.dart';
import 'package:first_priority_app/home/homeScreen/components/upcoming_event_card.dart';
import 'package:first_priority_app/home/homeScreen/components/devotional_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      child: Wrap(
        children: [
          DevotionalCard(),
          UpcomingEventCard(),
          NotificationsCard(),
        ],
      ),
    );
  }
}
