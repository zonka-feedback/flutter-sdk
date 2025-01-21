import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zonkafeedback_sdk/zonkafeedback_sdk.dart';

class AttributeForm extends StatefulWidget {
  @override
  _AttributeFormState createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm>
    with WidgetsBindingObserver {
  List<Map<String, String>> attributes = [
    {"key": "", "value": ""},
  ];
  String sdkToken = "Sgt8J2";
  String regionValue = "US";
  double heightValue = 1.8;
  void addAttribute() {
    setState(() {
      attributes.add({"key": "", "value": ""});
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ZFSurvey().sendAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }

  void runSurvey(String displayType) async {
    await ZFSurvey().init(
        token: sdkToken,
        zfRegion: regionValue,
        context: context,
        displayType: displayType,
        height: heightValue
        );
    final Map<String, String> customAttributes = {
      for (var attribute in attributes)
        if (attribute['key'] != null &&
            attribute['value'] != null &&
            attribute['value']!.isNotEmpty)
          attribute['key']!: attribute['value']!
    };
    ZFSurvey()
        .sendDeviceDetails(true)
        .sendCustomAttributes(customAttributes)
        .startSurvey();
  }

  void clearFunctionValue() {
    ZFSurvey().clear();
  }

  void removeAttribute(int index) {
    setState(() {
      attributes.removeAt(index);
    });
  }

  void clearAllAttributes() {
    setState(() {
      attributes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'IN APP SDK',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            // SDK Token Field
            TextFormField(
              onChanged: (value) {
                setState(() {
                  sdkToken = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'SDK Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                setState(() {
                  regionValue = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Region Value',
                border: OutlineInputBorder(),
              ),
            ),
   const SizedBox(height: 10),
 TextFormField(
              onChanged: (value) {
                setState(() {
                  heightValue = double.parse(value) ;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Height Value',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20), // Dynamic Attributes List
            Expanded(
              child: ListView.separated(
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 10);
                },
                itemCount: attributes.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      // Attribute Field
                      Expanded(
                        child: TextFormField(
                          initialValue: attributes[index]["key"],
                          decoration: InputDecoration(
                            hintText:
                                index == 0 ? 'contact_email' : 'Attribute',
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: TextStyle(
                                fontSize: size.height / 50,
                                color: Colors.grey.shade500),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            attributes[index]["key"] = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // Value Field
                      Expanded(
                        child: TextFormField(
                          initialValue: attributes[index]["value"],
                          decoration: InputDecoration(
                            hintText: index == 0 ? 'email@gmail.com' : 'Value',
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: TextStyle(
                                fontSize: size.height / 50,
                                color: Colors.grey.shade500),
                          ),
                          onChanged: (value) {
                            attributes[index]["value"] = value;
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      // Remove Button
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () => removeAttribute(index),
                      ),
                    ],
                  );
                },
              ),
            ),

            Column(
              children: [
                ElevatedButton(
                  onPressed: addAttribute,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          8), // Adjust the value as needed
                    ),
                  ),
                  child: Text(
                    'Add More',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: clearAllAttributes,
                      child: Text('Clear All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                    // Clear All Button
                    TextButton(
                      onPressed: clearFunctionValue,
                      child: Text('Clear Local Storage'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.blue,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                8), // Adjust the value as needed
                          ),
                        ),
                        onPressed: () {
                          runSurvey('popup');
                        },
                        child: Text(
                          'popup',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width / 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        runSurvey('slide-up');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              8), // Adjust the value as needed
                        ),
                      ),
                      child: Text(
                        'slide-up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Add More Button
          ],
        ),
      ),
    );
  }
}
