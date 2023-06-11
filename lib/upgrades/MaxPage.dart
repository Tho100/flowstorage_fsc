import 'package:flowstorage_fsc/themes/ThemeColor.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MaxPage extends StatefulWidget {

  const MaxPage({Key? key}) : super(key: key);

  @override
  State<MaxPage> createState() => _MaxPageState();
}

class _MaxPageState extends State<MaxPage> {

  String appBarTitle = "Ugprade";  

  late final WebViewController controller;
  //final String desiredUrl = 'https://checkout.stripe.com/c/pay/cs_test_a1NjhNEUVCBdOrV5AUOA6u7YPlGwG5lwHcWebW6VXCkHVBhH5I1aaNMoaw#fidkdWxOYHwnPyd1blpxYHZxWjA0SEoxXFxDN2l9V1M2Nn12YEpfaDczVWl8RFdubTc9VHI2ZFBVXTNdbmYwYWx0XD1kTVZHQ1RMQVI2VE1DYUlNT3FEPWZ2Yk5iUlV2d1NvM29AUjxBaGpQNTVsMXwwaHMxaycpJ3VpbGtuQH11anZgYUxhJz8ncWB2cVo8RFQ0M1w8TWczQmdjTnJmSFUneCUl';
  
  @override 
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onPageFinished: (url) {
        final currentUrl = controller.currentUrl;
        final newUrl = Uri.parse(url);
        if (currentUrl != newUrl) {
          setState(() {
            appBarTitle = "$newUrl";
          });
          print('Page URL has changed: $newUrl');
        }
      }))
      ..loadRequest(Uri.parse('https://buy.stripe.com/test_9AQ16Y9Hb6GbfKwcMP'));
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: ThemeColor.darkBlack,
        title: Text(
          appBarTitle
        ),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}