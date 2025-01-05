import 'package:flutter/material.dart';
import 'package:zonkafeedback_sdk/zonka_feedback.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  {



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: AttributeForm()
    );
  }
}



class AttributeForm extends StatefulWidget {
  @override
  _AttributeFormState createState() => _AttributeFormState();
}

class _AttributeFormState extends State<AttributeForm> with WidgetsBindingObserver {


  List<Map<String, String>> attributes = [
    {"key": "", "value": ""},
  ];
  String sdkToken = "Sgt8J2";
  String regionValue = "US";
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
    print("applycylemethodh ${state}");
    ZFSurvey().sendAppLifecycleState(state);
    super.didChangeAppLifecycleState(state);
  }





  void runSurvey() async {
    await  ZFSurvey().init(token: sdkToken ,zfRegion:regionValue ,context: context);

    final Map<String, String> customAttributes = {
      for (var attribute in attributes)
        if (attribute['key'] != null && attribute['value'] != null && attribute['value']!.isNotEmpty)
          attribute['key']!: attribute['value']!
    };

    print("attrinbutedvalue $customAttributes");
    ZFSurvey().sendDeviceDetails(true).sendCustomAttributes(customAttributes).startSurvey();


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
        title:const Text('IN APP SDK',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),backgroundColor: Colors.lightBlue,
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
              onChanged: (value){
                setState(() {
                  sdkToken  = value;
                });
              },
              decoration:const InputDecoration(
                labelText: 'SDK Token',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value){
                setState(() {
                  regionValue  = value;
                });
              },
              decoration:const InputDecoration(
                labelText: 'Region Value',
                border: OutlineInputBorder(),
              ),
            ),
            const  SizedBox(height: 20),   // Dynamic Attributes List
            Expanded(

              child: ListView.separated(
                separatorBuilder: (context, index){
                  return const SizedBox(height: 10);
                },
                itemCount: attributes.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      // Attribute Field
                      Expanded(
                        child: TextFormField(
                          initialValue:  attributes[index]["key"],
                          decoration: InputDecoration(
                            hintText: index == 0 ? 'contact_email': 'Attribute',
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: TextStyle(fontSize: size.height/50, color: Colors.grey.shade500),
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
                            hintText: index==0? 'email@gmail.com': 'Value',
                            border: OutlineInputBorder(),
                            contentPadding: const EdgeInsets.all(5),
                            hintStyle: TextStyle(fontSize: size.height/50,color: Colors.grey.shade500),
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
                  child: Text('Add More',style: TextStyle(color: Colors.white),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                SizedBox(height: 10),
                // Clear All Button
                TextButton(
                  onPressed: clearAllAttributes,
                  child: Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),

                Container(
                  width: size.width,
                  child: ElevatedButton(
                    onPressed: runSurvey,
                    child:  Text('RUN',style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
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