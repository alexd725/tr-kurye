import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class PdfReader extends StatefulWidget {
  final PDFDocument path;

  PdfReader({required this.path});

  @override
  State<PdfReader> createState() => _PdfReaderState();
}

class _PdfReaderState extends State<PdfReader> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pdf Viewer"), centerTitle: true),
      body: PDFViewer(
        document: widget.path,
      ),
    );
  }
}
