import 'package:flowstorage_fsc/themes/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MaxPage extends StatefulWidget {

  const MaxPage({Key? key}) : super(key: key);

  @override
  State<MaxPage> createState() => _MaxPageState();
}

class _MaxPageState extends State<MaxPage> {

  late final WebViewController controller;
  final paymentUrl = 'https://buy.stripe.com/test_9AQ16Y9Hb6GbfKwcMP';

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