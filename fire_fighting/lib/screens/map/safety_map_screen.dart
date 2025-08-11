import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;

class SafetyMapScreen extends StatefulWidget {
  final String mapAssetPath;
  const SafetyMapScreen({required this.mapAssetPath, super.key});

  @override
  State<SafetyMapScreen> createState() => _SafetyMapScreenState();
}

class _SafetyMapScreenState extends State<SafetyMapScreen> {
  String? _htmlContent;

  @override
  void initState() {
    super.initState();
    _loadHtml();
  }

  Future<void> _loadHtml() async {
    final html = await rootBundle.loadString(widget.mapAssetPath);
    setState(() {
      _htmlContent = html;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('서울 안전 지도')),
      body: _htmlContent == null
          ? Center(child: CircularProgressIndicator())
          : WebViewWidget(
              controller: WebViewController()
                ..setBackgroundColor(Colors.white)
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..loadHtmlString(_htmlContent!),
            ),
    );
  }
}