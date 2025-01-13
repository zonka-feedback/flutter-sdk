import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZfBottomSheetDialog {
  static Future<void> show({
    required BuildContext context,
    required String surveyUrl,
  }) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows content-driven height
      isDismissible: false, // Prevent accidental dismissal
      backgroundColor:
          Colors.transparent, // Transparent background for custom styling
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20, // Optional padding for better visibility
            bottom: MediaQuery.of(context)
                .viewInsets
                .bottom, // Respect the keyboard
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
            child: Container(
              color: Colors.white, // Background color of the bottom sheet
              child: WebViewWithLoader(surveyUrl: surveyUrl),
            ),
          ),
        );
      },
    );
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;

  const WebViewWithLoader({Key? key, required this.surveyUrl})
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
                content: Text('Failed to load page: ${error.description}'),
              ),
            );
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(Uri.parse(widget.surveyUrl));
  }

  void _handleJavaScriptMessage(String message) {
    if (message == 'zf-embed-expand-widget') {
      print("messagejanfle");
      setState(() {
        isExpanded = true;
      });
    } else if (message == 'zf-embed-submit-close') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Adjust height dynamically based on isExpanded
    double height = isExpanded ? MediaQuery.of(context).size.height / 1.8 : 270;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth resizing
      height: height,
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlue,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            tooltip: 'Close dialog',
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
