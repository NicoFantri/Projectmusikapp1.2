import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MusicWebView extends StatelessWidget {
  const MusicWebView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://gigsplay.com')); // Ganti URL dengan halaman yang ingin ditampilkan

    return Scaffold(
      appBar: AppBar(
        title: const Text('Berita Music'),
      ),
      body: WebViewWidget(controller: controller),
    );
  }
}