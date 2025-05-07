import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:app_links/app_links.dart';

class VnpayCheckoutPage extends StatefulWidget {
  final String payUrl;
  VnpayCheckoutPage(this.payUrl);

  @override
  _VnpayCheckoutPageState createState() => _VnpayCheckoutPageState();
}

class _VnpayCheckoutPageState extends State<VnpayCheckoutPage> {
  late final WebViewController _controller;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();
    // 1) Set up the WebViewController…
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (req) {
            final url = req.url;
            if (url.contains('vnpay_return.php')) {
              // parse query params
              final uri = Uri.parse(url);
              final responseCode = uri.queryParameters['vnp_ResponseCode'];
              final orderId = uri.queryParameters['vnp_TxnRef'];

              if (responseCode == '00') {
                Navigator.of(context)
                    .pop({'status': 'success', 'orderId': orderId});
              } else {
                Navigator.of(context)
                    .pop({'status': 'fail', 'orderId': orderId});
              }
              return NavigationDecision.prevent; // stop loading in WebView
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.payUrl));

    // 2) Listen for deep-link callbacks
    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'myapp' && uri.host == 'vnpay_result') {
        final status = uri.queryParameters['status'];
        final orderId = uri.queryParameters['orderId'];
        Navigator.of(context).pop({'status': status, 'orderId': orderId});
      }
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán VNPAY')),
      // 3) …and embed it via WebViewWidget:
      body: WebViewWidget(controller: _controller),
    );
  }
}
