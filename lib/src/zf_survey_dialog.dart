import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZFSurveyDialog {
  static Future<void> show({
    required BuildContext context,
    required String surveyUrl,
    required double height
  }) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: WebViewWithLoader(surveyUrl: surveyUrl, height: height,),
        ),
      ),
    );
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;
  final double height;
  const WebViewWithLoader({Key? key, required this.surveyUrl, required this.height})
      : super(key: key);

  @override
  _WebViewWithLoaderState createState() => _WebViewWithLoaderState();
}

class _WebViewWithLoaderState extends State<WebViewWithLoader> {
  bool _isLoading = true;
  bool isExpanded = false;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'messageHandler',
        onMessageReceived: (message) {
          _handleJavaScriptMessage(message.message);
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (error) {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to load page: ${error.description}')),
            );
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(widget.surveyUrl));
      
  }

  void _handleJavaScriptMessage(String message) {
    if (message == 'zf-embed-expand-widget') {
      print("expandedcalled");
      setState(() {
        isExpanded = true;
      });
    } else if (message == 'zf-embed-submit-close') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      width: 320,
     
      height: isExpanded ? size.height / widget.height : 270,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          WebViewWidget(controller: _webViewController),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            tooltip: 'Close dialog',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.lightBlue),
            ),
        ],
      ),
    );
  }
}
