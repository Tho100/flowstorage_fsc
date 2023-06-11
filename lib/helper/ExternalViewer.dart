import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ExternalViewer extends StatefulWidget {

  final Uint8List fileData;

  const ExternalViewer({Key? key, required this.fileData}) : super(key: key);

  @override
  _ExternalViewerState createState() => _ExternalViewerState();
}

class _ExternalViewerState extends State<ExternalViewer> {

  late WebViewController webController;
  late String base64Data;

  @override
  void initState() {
    super.initState();
    base64Data = base64.encode(widget.fileData);
    webController = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
    loadDocument();
  }

  void loadDocument() async {
    final url = 'data:application/vnd.openxmlformats-officedocument.wordprocessingml.document;base64,$base64Data';
    await webController.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(
        controller: webController,
      ),
    );
  }
}