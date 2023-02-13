import 'package:flutter/material.dart';

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
  // Code for the home page

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final fieldText = TextEditingController();
  int _selectedIndex = 0;
  final List<Widget> _children = [const HomePage(), const SettingsPage()];

  void clearText() {
    fieldText.clear();
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => _children[_selectedIndex]));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 69, 196, 255),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")
      //   ],
      //   currentIndex: _selectedIndex,
      //   onTap: _onNavTapped,
      // ),
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(child: TextBox(fieldText: fieldText)),
            ),
          ),
          Row(
            // Buttons
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                // This button is not functional yet
                onPressed: () {
                  // Add the text to speech functionality here
                },
                child: const Text("Text to Speech test"),
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
              ),
              ElevatedButton(
                // Clears the textBox
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Settings"),
        ),
        body: Center(child: Text("HI") //Slider(value: double,)
            ));
  }
}

class TextBox extends StatelessWidget {
  const TextBox({
    super.key,
    required this.fieldText,
  });

  final TextEditingController fieldText;

  @override
  Widget build(BuildContext context) {
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

class FontChanger extends StatefulWidget {
  const FontChanger({super.key});

  @override
  State<FontChanger> createState() => FontChangerState();
}

class FontChangerState extends State<FontChanger> {
  double _currentSliderValue = 20;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Slider(
            value: _currentSliderValue,
            max: 100,
            min: 10,
            onChanged: ((double value) {
              setState(() {
                _currentSliderValue = value;
              });
            })));
  }
}

class OptionsMenu extends StatelessWidget {
  const OptionsMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
