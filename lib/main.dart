import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wav/wav.dart';

// Value that allows the user to change the size of the text in the textbox
ValueNotifier<double> fontSize = ValueNotifier<double>(60.0);

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
  // Controller for the textbox
  final fieldText = TextEditingController();

  // Channels for the face detection
  static const platform = MethodChannel('aphasia_app/face_mesh_method');
  static const stream = EventChannel('aphasia_app/eye_tracking_output');

  // Keeps track of whether the eye tracking is on or off
  int count = 0;

  // Variable for the stream subscription
  late StreamSubscription _subscription;

  // Variables for the predicted eye position
  double _predictedX = 2.0;
  double _predictedY = 2.0;

  // Start listening to the event stream
  void _startListening() {
    _subscription = stream.receiveBroadcastStream().listen(_listenStream);
  }

  // Cancel listening to the event stream and move the red circle off the screen
  void _cancelListening() {
    _subscription.cancel();
    setState(() {
      _predictedX = 2.0;
      _predictedY = 2.0;
    });
  }

  // Get the values from the event stream
  void _listenStream(values) {
    setState(() {
      _predictedX = values[0];
      _predictedY = values[1];
      // print(_predictedX);
      // print(_predictedY);
    });
  }

  @override
  void initState() {
    super.initState();
    initTts();
  }

  @override
  void dispose() {
    fieldText.dispose();
    super.dispose();
    _flutterTts.stop();
  }

  initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.awaitSpeakCompletion(true);
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

    //print(selected);
    return selected;
  }

  late FlutterTts _flutterTts;
  String? _tts;

  final player = AudioPlayer();
  final note = AudioPlayer();

  // Tries the speak function until it works properly
  Future trySpeak(String word) async {
    if (word == "") {
      return;
    }
    bool success = false;
    while (!success) {
      try {
        success = await speak(word);
      } on FormatException catch (_) {
        success = false;
      }
      //print(success);
    }
  }

  // Breaks a word down into syllables and reads out the word with notes behind each syllable
  Future speak(String word) async {
    await _flutterTts.setVolume(1);
    await _flutterTts.setSpeechRate(0.1);
    await _flutterTts.setPitch(1);
    _tts = word;

    if (_tts != null) {
      if (_tts!.isNotEmpty) {
        await _flutterTts.synthesizeToFile(_tts!, 'tts.wav');
        final ttsDir = await getExternalStorageDirectory();
        String ttsPath = ttsDir!.path + "/tts.wav";
        final wav = await Wav.readFile(ttsPath);
        final condensed_data = <double>[];
        final condensed_time = <double>[];
        String data = "";
        for (var i = 0; i < wav.channels[0].length; i += 500) {
          if (i + 400 < wav.channels[0].length) {
            double average = 0;
            for (var x = 0; x < 5; x++) {
              average += wav.channels[0][i + (100 * x)].abs();
            }
            average = average / 5;
            condensed_data.add(average);
            double time = i / 24000;
            condensed_time.add(time);
            data += time.toStringAsFixed(2) + ": " + average.toString() + "\n";
          }
        }
        List<List<double>> syllables = [];
        bool lookingForStop = false;
        for (var i = 0; i < condensed_data.length; i++) {
          if (lookingForStop) {
            if (condensed_data[i].abs() < 0.01) {
              if (i + 1 < condensed_data.length &&
                  condensed_data[i + 1].abs() < 0.01) {
                syllables[syllables.length - 1].add(condensed_time[i]);
                lookingForStop = false;
              }
            }
          } else {
            if (condensed_data[i].abs() >= 0.01) {
              syllables.add([condensed_time[i]]);
              lookingForStop = true;
            }
          }
        }
        //print(data);
        //print(syllables);
        await Future.delayed(const Duration(milliseconds: 500));
        final notes = <String>['g4.mp3', 'f4.mp3', 'e4.mp3', 'd4.mp3'];
        int current_note = 1;
        player.play(DeviceFileSource(ttsPath), volume: .25);
        await Future.delayed(
            Duration(milliseconds: (syllables[0][0] * 1000).round()));

        note.play(AssetSource(notes[0]));
        for (var i = 1; i < syllables.length; i++) {
          await Future.delayed(
              Duration(
                  milliseconds: (syllables[i][0] * 1000).round() -
                      syllables[i - 1][0].round()),
              () {});
          note.play(AssetSource(notes[current_note]));
          current_note++;
          if (current_note == 4) {
            current_note = 0;
          }
        }
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // Screen height and width
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
                                  trySpeak(selected);
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
                            var status = await Permission.camera.status;

                            if (!status.isGranted) {
                              await Permission.camera.request();
                            }

                            // Code to either start or stop the eye tracking
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
      // Need to add functionality to allow this to work as a cursor
      Positioned(
        // Commenting out the variables for the demo video to hide the red circle, change back when we have the CNN output
        top: 2.0 * (height - 50), //_predictedX * (height - 50),
        left: 2.0 * (width - 50), //_predictedY * (width - 50),
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
