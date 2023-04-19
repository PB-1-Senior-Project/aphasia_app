import 'package:flutter/material.dart';
import 'dart:async';
import 'settings.dart';
import 'about.dart';
import 'stream.dart';

//StreamController<ThemeData> currentTheme = StreamController ();

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ThemeData>(
      initialData: lightTheme,
      stream: currentTheme.stream,
      builder: (context, snapshot) {
        return MaterialApp (
          home: const HomePage(),
          theme: snapshot.data,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
        );
      }
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
      //backgroundColor: const Color.fromARGB(255, 69, 196, 255),
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
                  print (ThemeData.light(useMaterial3: true));

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
        //backgroundColor: const Color.fromARGB(255, 2, 189, 164),
      ),
      drawer: const OptionsMenu(),
    );
  }
}

class TextBox extends StatefulWidget {
  const TextBox({
    super.key,
    required this.fieldText,
  });

  final TextEditingController fieldText;

  @override
  State<TextBox> createState() => _TextBoxState();
}

class _TextBoxState extends State<TextBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Text Box
      width: 1000,
      height: 250,
      child: TextField(
        controller: widget.fieldText,
        cursorColor: Colors.black,
        style: current,
        maxLines: 5,
        onChanged: (value) {
          setState(() {
            
          });
          print (current.toString());
        },
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

class OptionsMenu extends StatelessWidget {
  const OptionsMenu({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingsPage()));
              },
            ),
            ListTile(
              leading: const Icon (Icons.info_rounded),
              title: const Text("About"),
              onTap: () {
                Navigator.push (
                  context,
                  MaterialPageRoute (builder: (context) => const AboutPage())
                );
              }
            )
          ],
        ));
  }
}
