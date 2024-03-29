import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wav/wav.dart';
import 'about.dart';
import 'stream.dart';
import 'package:volume_control/volume_control.dart';
import 'stream.dart' as stream;

// Value that allows the user to change the size of the text in the textbox
ValueNotifier<double> fontSize = ValueNotifier<double>(60.0);
ValueNotifier<String> fontLabel = ValueNotifier<String>('lar');
ValueNotifier<String> theme = ValueNotifier<String>('dark');
ValueNotifier<double> volume = ValueNotifier<double>(0.5);
ValueNotifier<double> ttsSpeed = ValueNotifier<double>(0.5);

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
    return StreamBuilder<ThemeData>(
        initialData: darkTheme,
        stream: currentTheme.stream,
        builder: (context, snapshot) {
          return MaterialApp(
            home: const HomePage(),
            theme: snapshot.data,
            darkTheme: darkTheme,
            themeMode: ThemeMode.light,
          );
        });
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
    await _flutterTts.setVolume(volume.value); // 1
    await _flutterTts.setSpeechRate(ttsSpeed.value); // 0.1
    await _flutterTts.setPitch(1);
    _tts = word;

    if (_tts != null) {
      if (_tts!.isNotEmpty) {
        await _flutterTts.synthesizeToFile(_tts!, 'tts.wav');
        final ttsDir = await getExternalStorageDirectory();
        String ttsPath = "${ttsDir!.path}/tts.wav";
        final wav = await Wav.readFile(ttsPath);
        final condensedData = <double>[];
        final condensedTime = <double>[];
        String data = "";
        for (var i = 0; i < wav.channels[0].length; i += 500) {
          if (i + 400 < wav.channels[0].length) {
            double average = 0;
            for (var x = 0; x < 5; x++) {
              average += wav.channels[0][i + (100 * x)].abs();
            }
            average = average / 5;
            condensedData.add(average);
            double time = i / 24000;
            condensedTime.add(time);
            data += "${time.toStringAsFixed(2)}: $average\n";
          }
        }
        List<List<double>> syllables = [];
        bool lookingForStop = false;
        for (var i = 0; i < condensedData.length; i++) {
          if (lookingForStop) {
            if (condensedData[i].abs() < 0.01) {
              if (i + 1 < condensedData.length &&
                  condensedData[i + 1].abs() < 0.01) {
                syllables[syllables.length - 1].add(condensedTime[i]);
                lookingForStop = false;
              }
            }
          } else {
            if (condensedData[i].abs() >= 0.01) {
              syllables.add([condensedTime[i]]);
              lookingForStop = true;
            }
          }
        }
        //print(data);
        //print(syllables);
        await Future.delayed(const Duration(milliseconds: 500));
        final notes = <String>['g4.mp3', 'f4.mp3', 'e4.mp3', 'd4.mp3'];
        int currentNote = 1;
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
          note.play(AssetSource(notes[currentNote]));
          currentNote++;
          if (currentNote == 4) {
            currentNote = 0;
          }
        }
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: ValueListenableBuilder<double>(
                      valueListenable: fontSize,
                      builder: (context, value, child) {
                        return SizedBox(
                          width: 1000,
                          height: 250,
                          child: TextField(
                            controller: fieldText,
                            maxLines: 10,
                            onTap: () {
                              String selected = getSelectedWord();
                              trySpeak(selected);
                            },
                            style: TextStyle(
                              fontSize: value,
                            ),
                            decoration: const InputDecoration(
                              filled: true,
                              hintText: "Enter Text Here",
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      },
                      child: const SettingsPage())),
            ),
          ),
          Center(
            child: Row(
              // Buttons
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
          )
        ],
      ),
      appBar: AppBar(
        title: const Text("Visually Assisted Speech Therapy"),
        //backgroundColor: const Color.fromARGB(255, 2, 189, 164),
      ),
      drawer: const OptionsMenu(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    initVolumeState();
  }

  Future<void> initVolumeState() async {
    if (!mounted) return;

    volume.value = await VolumeControl.volume;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Column(children: [
          SettingsChanger(
            //package volume_watcher can be added to make the slider automatically move when device's volume is changed
            settingName: 'Volume',
            settingWidget: Slider(
                value: volume.value,
                label: volume.value.toString(),
                min: 0,
                max: 1,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    volume.value = value;
                    VolumeControl.setVolume(value);
                  });
                }),
          ),
          SettingsChanger(
            settingName: 'Text Size',
            padding: 50,
            settingWidget: DropdownButton(
              value: fontLabel.value,
              items: [
                DropdownMenuItem(
                    value: 'lar',
                    child: Text('Large',
                        style: stream.wordTheme.textTheme.bodyMedium)),
                DropdownMenuItem(
                    value: 'med',
                    child: Text('Medium',
                        style: stream.wordTheme.textTheme.bodyMedium)),
                DropdownMenuItem(
                    value: 'sma',
                    child: Text('Small',
                        style: stream.wordTheme.textTheme.bodyMedium)),
              ],
              onChanged: (string) {
                if (string == null) return;
                if (string == 'sma') {
                  stream.current = stream.wordTheme.textTheme.bodySmall;
                  fontSize.value = 20.0;
                  fontLabel.value = 'sma';
                } else if (string == 'med') {
                  stream.current = stream.wordTheme.textTheme.bodyMedium;
                  fontSize.value = 40.0;
                  fontLabel.value = 'med';
                } else {
                  stream.current = stream.wordTheme.textTheme.bodyLarge;
                  fontSize.value = 60.0;
                  fontLabel.value = 'lar';
                }

                setState(() {});
              },
            ),
          ),
          SettingsChanger(
            settingName: 'Text-to-Speech Speed',
            settingWidget: Slider(
              value: ttsSpeed.value,
              min: 0,
              max: 1,
              divisions: 10,
              label: ttsSpeed.value.toString(),
              onChanged: (double value) {
                setState(() {
                  ttsSpeed.value = value;
                });
              },
            ),
          ),
          SettingsChanger(
            settingName: 'Theme',
            padding: 50,
            settingWidget: DropdownButton<String>(
              value: theme.value,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
              ],
              onChanged: (string) {
                if (string == 'light') {
                  stream.currentTheme.add(stream.lightTheme);
                  theme.value = 'light';
                } else {
                  stream.currentTheme.add(stream.darkTheme);
                  theme.value = 'dark';
                }

                setState(() {});
              },
            ),
          ),
        ]));
  }
}

class SettingsChanger extends StatefulWidget {
  const SettingsChanger({
    super.key,
    required this.settingName,
    required this.settingWidget,
    this.padding = 0,
  });

  final String settingName;
  final Widget settingWidget;
  final double padding;

  @override
  State<SettingsChanger> createState() => _SettingsChangerState();
}

class _SettingsChangerState extends State<SettingsChanger> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(widget.settingName, style: stream.wordTheme.textTheme.bodyMedium),
        SizedBox(width: widget.padding),
        widget.settingWidget,
      ],
    );
  }
}

class OptionsMenu extends StatelessWidget {
  const OptionsMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Code for the pop out menu
    return Drawer(
        //backgroundColor: const Color.fromARGB(255, 255, 245, 245),
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(
          height: 88,
          child: DrawerHeader(
            //decoration: BoxDecoration(color: Color.fromARGB(255, 2, 189, 164)),
            child: Padding(
              padding: EdgeInsets.zero,
              child: Text(
                "Menu",
                style: TextStyle(
                    //color: Color.fromARGB(255, 255, 255, 255),
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
        ListTile(
            leading: const Icon(Icons.info_rounded),
            title: const Text("About"),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AboutPage()));
            })
      ],
    ));
  }
}
