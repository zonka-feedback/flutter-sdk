import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ZFSurveyDialog {

  static Future<void> show({required BuildContext context, required String surveyUrl}) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
          insetPadding: EdgeInsets.zero,
            child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(10),),
                child: WebViewWithLoader(
                  surveyUrl: surveyUrl,
                ))));
  }
}

class WebViewWithLoader extends StatefulWidget {
  final String surveyUrl;
  const WebViewWithLoader({super.key, required this.surveyUrl});

  @override
  _WebViewWithLoaderState createState() => _WebViewWithLoaderState();
}

class _WebViewWithLoaderState extends State<WebViewWithLoader> {
  bool _isLoading = true;
  late InAppWebViewController _webViewController;
  bool switchHeight = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      alignment: Alignment.center,
      width: 320, // Match the width of your XML CardView
      height: switchHeight ? 270 : size.height/1.8, //
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.surveyUrl), // Fixed Uri parsing
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              _webViewController.addJavaScriptHandler(
                handlerName: 'messageHandler',
                callback: (args) {
                  if(args[0] == 'zf-embed-expand-widget'){
                    setState(() {
                      switchHeight = false;
                    });
                  }
                  else if(args[0] == 'zf-embed-submit-close'){
                    Navigator.of(context).pop();
                  }
                  return {"status": "Message received successfully!"};
                },
              );
            },
            onLoadStop: (controller, url) async {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          Positioned(
            left: size.width/1.3,
            bottom: switchHeight ?  size.height/3.5 : size.height/2 ,
            child: IconButton(
              focusColor: Colors.black,
              icon: const Icon(
                Icons.close,
                weight: 25,
                color: Colors.black, // Icon color
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Colors.lightBlue,
                      ),
                    ),
        ],
      ),
    );
  }
}
