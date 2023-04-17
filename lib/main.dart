import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';

// Value that allows the user to change the size of the text in the textbox
ValueNotifier<double> fontSize = ValueNotifier<double>(60.0);

// Gets the screen size for use with the output of the CNN
// Size screenSize = WidgetsBinding.instance.window.physicalSize;
// double width = screenSize.width;
// double height = screenSize.height;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fieldText = TextEditingController();
  static const platform = MethodChannel('aphasia_app/face_mesh_method');
  static const stream = EventChannel('aphasia_app/eye_tracking_output');
  int count = 0;
  late StreamSubscription _subscription;
  double _predictedX = 1.0;
  double _predictedY = 1.0;

  void _startListening() {
    _subscription = stream.receiveBroadcastStream().listen(_listenStream);
  }

  void _cancelListening() {
    _subscription.cancel();
  }

  void _listenStream(values) {
    setState(() {
      _predictedX = values[0];
      _predictedY = values[1];
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    fieldText.dispose();

    super.dispose();
  }

  // Clears the text in the textbox
  void clearText() {
    fieldText.clear();
  }

  // Gets the word that the user is currently selecting
  String getSelectedWord() {
    int start = fieldText.selection.start;
    late int end;
    String words = fieldText.text;

    if (fieldText.text.isEmpty || start == fieldText.text.length) {
      return "";
    }
    if (words[start] == " ") {
      for (int i = start; i < words.length; i--) {
        if (words[i] != " ") {
          start = i;
          break;
        }
      }
    }
    for (int i = start; i >= 0; i--) {
      if (words[i] == " " || i == 0) {
        if (i == 0) {
          start = 0;
        } else {
          start = i + 1;
        }

        break;
      }
    }
    for (int i = start; i < words.length; i++) {
      if (words[i] == " " || i == words.length - 1) {
        if (i == words.length - 1) {
          end = i + 1;
        } else {
          end = i;
        }

        break;
      }
    }

    String selected = words.substring(start, end);

    print(selected);
    return selected;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // Code for the home page
    return Stack(children: [
      Scaffold(
        backgroundColor: const Color.fromARGB(255, 69, 196, 255),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                      // Code for the Textbox
                      child: ValueListenableBuilder<double>(
                          valueListenable: fontSize,
                          builder: (context, value, child) {
                            return SizedBox(
                              width: 1000,
                              height: 250,
                              child: TextField(
                                controller: fieldText,
                                cursorColor: Colors.black,
                                onTap: () {
                                  String selected = getSelectedWord();
                                  // Implement the text to speech here, have the TTS read out the value of the variable "selected"
                                  // read(selected)
                                },
                                style: TextStyle(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                    fontSize: value),
                                maxLines: 5,
                                decoration: const InputDecoration(
                                  filled: true,
                                  hintText: "Enter Text Here",
                                  fillColor: Color.fromARGB(255, 255, 255, 255),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const SettingsPage())
                      // End of Textbox code
                      ),
                ),
              ),
              Center(
                child: Row(
                  // Code for buttons
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                    ),
                    // Starts the face detection
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 12.0, 0),
                      child: ElevatedButton(
                          onPressed: () async {
                            if (count % 2 == 0) {
                              _startListening();
                            } else {
                              _cancelListening();
                            }
                            count++;

                            await platform.invokeMethod("startFaceDetection");
                          },
                          child: const Text("Activate Eye Tracking")),
                    ),
                    // Clears the text in the textbox
                    ElevatedButton(
                      onPressed: () {
                        clearText();
                      },
                      child: const Text("Clear the Textbox"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Code for the bar at the top of the app
        appBar: AppBar(
          title: const Text("Visually Assisted Speech Therapy"),
          backgroundColor: const Color.fromARGB(255, 2, 189, 164),
        ),
        drawer: const Menu(),
      ),

      // NOT WORKING WITH CNN OUTPUT
      // Code for the cursor that follows the user's gaze
      Positioned(
        top: _predictedX * (height - 50),
        left: _predictedY * (width - 50),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      )
    ]);
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  ValueListenable<double> textSize = ValueNotifier(60);

  @override
  Widget build(BuildContext context) {
    // Code for the settings page

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Column(children: [
        const Padding(
          padding: EdgeInsets.only(top: 16.0),
          child: Text(
            "Font Size",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Center(
            // Code for changing the font size
            child: Slider(
          value: fontSize.value,
          max: 100,
          min: 10,
          divisions: 100,
          label: fontSize.value.toString(),
          onChanged: (double value) {
            setState(() {
              fontSize.value = value.roundToDouble();
            });
          },
        )),
        const Text(
          "The eye tracking will work better with larger values, \n 60 or higher is recommended",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ]),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Code for the pop out menu
    return Drawer(
        backgroundColor: const Color.fromARGB(255, 255, 245, 245),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(
              height: 88,
              child: DrawerHeader(
                decoration:
                    BoxDecoration(color: Color.fromARGB(255, 2, 189, 164)),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Text(
                    "Menu",
                    style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 24),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            )
          ],
        ));
  }
}
