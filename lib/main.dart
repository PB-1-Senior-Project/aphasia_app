import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

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

  @override
  void dispose() {
    fieldText.dispose();
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
      body: Column(
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
          )
        ],
      ),
      appBar: AppBar(
        title: const Text("Visually Assisted Speech Therapy"),
        backgroundColor: const Color.fromARGB(255, 2, 189, 164),
      ),
      drawer: const Menu(),
    );
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
