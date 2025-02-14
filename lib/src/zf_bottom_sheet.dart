import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZfBottomSheetDialog {
  static Future<void> show(
      {required BuildContext context,
      required String surveyUrl,
      required double expandedHeight,
      required double fixedHeight,
      required String crossIconPosition}) async {
    return showModalBottomSheet(
      context: context,   
      isScrollControlled: true, // Allows content-driven height
      isDismissible: false, // Prevent accidental dismissal
      backgroundColor: Colors.transparent, // Transparent background for custom styling
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
              child: WebViewWithLoader(
                surveyUrl: surveyUrl,
                expandedHeight: expandedHeight,
                fixedHeight: fixedHeight,
                crossIcon: crossIconPosition,
              ),
            ),
          ),
        );
      },
    );
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;
  final double fixedHeight;
  final double expandedHeight;
  final String crossIcon;
  const WebViewWithLoader(
      {Key? key,
      required this.surveyUrl,
      required this.expandedHeight,
      required this.fixedHeight,
      required this.crossIcon})
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
      setState(() {
        isExpanded = true;
      });
    } else if (message == 'zf-embed-submit-close') {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = isExpanded ? widget.expandedHeight : widget.fixedHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth resizing
      height: height,
      child: Stack(
      alignment: Alignment.topCenter,
      
        children: [
      
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.lightBlue,
              ),
            ),
              Container(
                width: 360,
                color: Colors.transparent,
                margin:  const EdgeInsets.only(left: 10, top: 21),
                child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.black),
                            alignment: widget.crossIcon =="right" ?  Alignment.topRight:Alignment.topLeft,
                            tooltip: 'Close dialog',
                            iconSize: 24,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
              ),
        ],
      ),
    );
  }
}
