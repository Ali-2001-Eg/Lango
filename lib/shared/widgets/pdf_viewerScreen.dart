import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'package:whatsapp_clone/shared/utils/colors.dart';
import 'package:whatsapp_clone/shared/utils/functions.dart';

class PdfViewerScreen extends StatelessWidget {
  const PdfViewerScreen({Key? key, required this.title, required this.pdfPath})
      : super(key: key);
  final String title;
  final String pdfPath;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title, style: getTextTheme(context)),
      ),
      body: SfPdfViewer.network(
        pdfPath,
      ),
    );
  }
}
