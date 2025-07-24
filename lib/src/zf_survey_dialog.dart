import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZFSurveyDialog {
  static Future<void> show(
      {required BuildContext context,
      required String surveyUrl,
      required bool autoClose,
      required double expandedHeight,
      required double fixedHeight,
      required String crossIconPosition}) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        insetPadding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: WebViewWithLoader(
            surveyUrl: surveyUrl,
            fixedHeight: fixedHeight,
            expandedHeight: expandedHeight,
            crossIconPosition: crossIconPosition,
            autoClose: autoClose,
          ),
        ),
      ),
    );
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;
  final double fixedHeight;
  final double expandedHeight;
  final String crossIconPosition;
  final bool autoClose;
  const WebViewWithLoader(
      {Key? key,
      required this.surveyUrl,
      required this.fixedHeight,
      required this.expandedHeight,
      required this.autoClose,
      required this.crossIconPosition})
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
      setState(() {
        isExpanded = true;
      });
    } else if (message == 'zf-embed-submit-close' && widget.autoClose) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double height = isExpanded ? widget.expandedHeight : widget.fixedHeight;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      width: size.width / 1.09,
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
        // alignment: widget.crossIconPosition =="left" ? AlignmentDirectional.topStart:AlignmentDirectional.topEnd,
        children: [
          Stack(
            children: [
              WebViewWidget(
                controller: _webViewController,
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.lightBlue,
                  ),
                ),
            ],
          ),
          Container(
            alignment: widget.crossIconPosition == "right"
                ? Alignment.topRight
                : Alignment.topLeft,
            color: Colors.transparent,
            // margin: const EdgeInsets.only(left: 10, top: 21),
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              alignment: widget.crossIconPosition == "right"
                  ? Alignment.topRight
                  : Alignment.topLeft,
              tooltip: 'Close dialog',
              iconSize: 24,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),

          // if (_isLoading)
          //   const Center(
          //     child: CircularProgressIndicator(color: Colors.lightBlue),
          //   ),
        ],
      ),
    );
  }
}
