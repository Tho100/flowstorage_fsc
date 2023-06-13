import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SupremePage extends StatefulWidget {
  const SupremePage({super.key});

  @override
  State<SupremePage> createState() => _SupremePage();
}

class _SupremePage extends State<SupremePage> {

  late final WebViewController controller;
  final paymentUrl = "";

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(paymentUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ThemeColor.darkBlack,
        title: const Text(
          "Upgrade Plan"
        ),
      ),
     body: WebViewWidget(
      controller: controller,
     ),
    );
  }
}