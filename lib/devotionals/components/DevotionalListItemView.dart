import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_priority_app/devotionals/devotionals_details.dart';
import 'package:first_priority_app/models/devotional.dart';
import 'package:first_priority_app/widgets/pill_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionalListItemView extends StatelessWidget {
  final Devotional devotional;
  final DateFormat dateFormat = DateFormat('MMM d');

  DevotionalListItemView({@required this.devotional});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            children: [
              if (devotional.imageUrl != null && devotional.imageUrl.isNotEmpty)
                Image(
                  image: CachedNetworkImageProvider(devotional.imageUrl),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            devotional.title,
                            style:
                                Theme.of(context).textTheme.headline1.copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                          if (devotional.startDate != null)
                            Text(
                                "${dateFormat.format(devotional.startDate)} - ${dateFormat.format(devotional.endDate)}")
                        ],
                      ),
                    ),
                    if (devotional.planUrl != null)
                      Flexible(
                        child: PillButton(
                          child: Text('READ'),
                          onTap: () {
                            if (devotional.planUrl != null &&
                                devotional.planUrl.isNotEmpty) {
                              launch(devotional.planUrl);
                            } else {
                              Get.to(
                                () => DevotionalsDetailsScreen(
                                  devotional: devotional,
                                ),
                              );
                            }
                          },
                        ),
                      )
                  ],
                ),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}
