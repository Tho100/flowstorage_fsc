import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Expresspage extends StatefulWidget {
  const Expresspage({super.key});

  @override
  State<Expresspage> createState() => _Expresspage();
}

class _Expresspage extends State<Expresspage> {

  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse('https://flutter.dev'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text("Upgrade Account - Flowstorage",),
      ),
     body: WebViewWidget(
      controller: controller,
     ),
    );
  }
}