import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_priority_app/models/devotional.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DevotionalsDetailsScreen extends StatefulWidget {
  final Devotional devotional;

  DevotionalsDetailsScreen({this.devotional});

  @override
  _DevotionalsDetailsScreenState createState() =>
      _DevotionalsDetailsScreenState();
}

class _DevotionalsDetailsScreenState extends State<DevotionalsDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.devotional.title),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Material(
                elevation: 5,
                child: Image(
                  width: Get.width,
                  height: Get.height / 3,
                  image: CachedNetworkImageProvider(widget.devotional.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await canLaunch(widget.devotional.videoUrl)
                      ? await launch(widget.devotional.videoUrl)
                      : ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Cannot open video.'),
                          ),
                        );
                },
                child: Text("Devotional Video"),
              ),
              Container(
                margin: EdgeInsets.all(10),
                child: Text(widget.devotional.description),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
