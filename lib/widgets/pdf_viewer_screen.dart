import 'package:first_priority_app/widgets/back_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String url;

  const PdfViewerScreen({
    Key key,
    this.title,
    this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BackAppBar(
        title: title,
        actionIcon: Icons.download,
        onActionPressed: () async {
          await canLaunch(url)
              ? await launch(url)
              : ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text("Unable to download PDF"),
                ));
        },
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
