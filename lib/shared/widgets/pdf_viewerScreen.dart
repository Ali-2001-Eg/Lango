import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends ConsumerWidget {
  const PdfViewerScreen({Key? key, required this.title, required this.pdfPath})
      : super(key: key);
  final String title;
  final String pdfPath;
  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: SfPdfViewer.network(
        pdfPath,
      ),
    );
  }
}
