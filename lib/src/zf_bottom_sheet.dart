import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class ZfBottomSheetDialog {
  static Future<void> show(
      {required BuildContext context,
      required String surveyUrl,
      required bool autoClose,
      required double expandedHeight,
      required double fixedHeight,
      required String closeIconType,
      required String crossIconPosition}) async {
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
                child: WebViewWithLoader(
                  surveyUrl: surveyUrl,
                  expandedHeight: expandedHeight,
                  fixedHeight: fixedHeight,
                  autoClose: autoClose,
                  crossIcon: crossIconPosition,
                  closeIconType: closeIconType,
                ),
              ),
            ),
          );
        });
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;
  final double fixedHeight;
  final double expandedHeight;
  final String closeIconType;
  final bool autoClose;
  final String crossIcon;
  const WebViewWithLoader(
      {Key? key,
      required this.surveyUrl,
      required this.closeIconType,
      required this.expandedHeight,
      required this.autoClose,
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
      // Clear cache and cookies to prevent caching issues
      ..clearCache()
      ..clearLocalStorage()
      // Add cache-busting parameter to URL
      ..loadRequest(Uri.parse(_addCacheBuster(widget.surveyUrl)));
  }

  // Add cache-busting parameter to URL
  String _addCacheBuster(String url) {
    final uri = Uri.parse(url);
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    
    // Add or update the cache-busting parameter
    final newQueryParameters = Map<String, String>.from(uri.queryParameters);
    newQueryParameters['_t'] = timestamp;
    
    return uri.replace(queryParameters: newQueryParameters).toString();
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
    double height = isExpanded ? widget.expandedHeight : widget.fixedHeight;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth resizing
      height: height,
      child: Stack(
        alignment: Alignment.topCenter,
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
          Container(
            width: 360,
            color: Colors.transparent,
            margin: const EdgeInsets.only(left: 10, top: 21),
            child: IconButton(
              icon: widget.closeIconType == 'icon1' ? const Icon(Icons.close, color: Colors.black) :  widget.closeIconType == 'icon2'? SvgPicture.asset(
                'assets/icons/close.svg',
                package: 'zonkafeedback_sdk',
                width: 24,
                height: 24,
              ):Container(),
              alignment: widget.crossIcon == "right"
                  ? Alignment.topRight
                  : Alignment.topLeft,
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
