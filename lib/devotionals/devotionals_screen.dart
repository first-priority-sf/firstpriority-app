import 'package:first_priority_app/devotionals/components/DevotionalListItemView.dart';
import 'package:first_priority_app/devotionals/devotionals_controller.dart';
import 'package:first_priority_app/models/devotional.dart';
import 'package:first_priority_app/widgets/text/title_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DevotionalsScreen extends StatelessWidget {
  final DevotionalsController _controller = Get.put(DevotionalsController());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Devotional>>(
      future: _controller.get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.data.isEmpty) {
          return Center(
            child: TitleText("No Devotionals"),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(4),
          child: Wrap(
            runSpacing: 4,
            children: List.generate(snapshot.data.length, (index) {
              return DevotionalListItemView(
                devotional: snapshot.data[index],
              );
            }),
          ),
        );
      },
    );
  }
}
