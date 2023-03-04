import 'dart:io';
import 'dart:typed_data';
import 'package:throttling/throttling.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
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
  //static const platform = MethodChannel('aphasia_app/face_mesh_method');
  //static const _imageChannel = EventChannel('aphasia_app/face_mesh_channel');
  bool _isStreaming = false;

  late CameraController controller;
  late List<CameraDescription> _cameras;
  //late Image _testImage;

  Future<void> _initCamera() async {
    // await Permission.mediaLibrary.request();
    // await Permission.accessMediaLocation.request();
    // await Permission.photos.request();
    // await Permission.manageExternalStorage.request();

    _cameras = await availableCameras();
    controller = CameraController(_cameras[1], ResolutionPreset.low);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  // Future<int> startFaceDetection(Image image) async {
  //   int testMessage;

  //   try {
  //     final int result =
  //         await platform.invokeMethod('startFaceDetection', {'image': image});
  //     testMessage = result;
  //   } on PlatformException catch (e) {
  //     debugPrint('debug: $e');
  //     testMessage = -2;
  //   }

  //   setState(() {
  //     _testMessage = testMessage;
  //   });
  //   return testMessage;
  // }

  @override
  void dispose() {
    fieldText.dispose();
    controller.dispose();
    super.dispose();
  }

  // Clears the text in the textbox
  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Code for the home page
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 69, 196, 255),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                    child: TextBox(
                  fieldText: fieldText,
                )),
              ),
            ),
            Row(
              // Code for buttons
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // This button is not functional yet
                ElevatedButton(
                  onPressed: () {
                    // Add the text to speech functionality here
                  },
                  child: const Text("Text to Speech test"),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                // Clears the textBox
                ElevatedButton(
                  onPressed: () {
                    clearText();
                  },
                  child: const Text("Clear the Textbox"),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () async {
                    if (!controller.value.isInitialized) {
                      Container();
                    } else {
                      try {
                        if (_isStreaming) {
                          controller.stopImageStream();
                          controller.dispose();
                          _isStreaming = false;
                        } else {
                          //final dataStream =
                          // _imageChannel.receiveBroadcastStream().distinct();
                          //.map((dynamic event) => intToConne)
                          _isStreaming = true;
                          controller.startImageStream((image) async {
                            List<int> strides =
                                Int32List(image.planes.length * 2);
                            int index = 0;
                            final bytes = image.planes.map((plane) {
                              strides[index] = (plane.bytesPerRow);
                              index++;
                              strides[index] = (plane.bytesPerPixel)!;
                              index++;
                              return plane.bytes;
                            }).toList();
                            //final thr = Throttling(
                            //    duration: const Duration(milliseconds: 50));
                            await const MethodChannel(
                                    'aphasia_app/face_mesh_method')
                                .invokeMethod("startFaceDetection", {
                              'byteList': bytes,
                              'height': image.height,
                              'width': image.width,
                              'strides': strides
                            });
                            //await thr.close();

                            //_processImage(image);
                            //print("object");
                            //print('Beef');
                            //Image tempImage;
                            //Image tempImage = image as Image; // This is causing the error, denies permission, happens when using the image class
                            //print(tempImage.runtimeType);
                            //print('Stew');
                            // print(tempImage.);

                            //startFaceDetection(tempImage);
                            // Send to native here?
                            // setState(() {
                            //   _testImage = test;
                            // });
                          });
                        }
                      } on PlatformException catch (e) {
                        throw CameraException(e.code, e.message);
                      }
                      // Navigator.of(context).push(
                      //     MaterialPageRoute(builder: (context) => _testImage));
                    }
                  },
                  child: const Text("Face Recognition Test")),
            ),
            //Text(_testMessage.toString()),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text("Visually Assisted Speech Therapy"),
        backgroundColor: const Color.fromARGB(255, 2, 189, 164),
      ),
      drawer: const Menu(),
    );
  }
}

class CreateView extends StatelessWidget {
  const CreateView({
    super.key,
    required CameraController controller,
  }) : _controller = controller;

  final CameraController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        CameraPreview(_controller),
      ],
    ));
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  double _currentSliderValue = 60;

  double getSliderValue() {
    return _currentSliderValue.round().toDouble();
  }

  @override
  Widget build(BuildContext context) {
    // Code for the settings page

    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Column(
          children: [
            const Text(
              "NOT IMPLEMENTED YET",
              style: TextStyle(fontSize: 32),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text(
                "Font Size",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
                child: Slider(
              value: _currentSliderValue,
              max: 100,
              min: 10,
              divisions: 100,
              label: _currentSliderValue.round().toString(),
              onChanged: (double value) {
                setState(() {
                  _currentSliderValue = value;
                });
              },
            )),
            const Text(
              "The eye tracking will work better with larger values, \n 60 or higher is recommended",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ));
  }
}

class TextBox extends StatelessWidget {
  const TextBox({super.key, required this.fieldText});

  final TextEditingController fieldText;

  @override
  Widget build(BuildContext context) {
    // Code for the textbox on the home page
    return SizedBox(
      // Text Box
      width: 1000,
      height: 250,
      child: TextField(
        controller: fieldText,
        cursorColor: Colors.black,
        style:
            const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 60),
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
