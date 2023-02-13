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

  void clearText() {
    fieldText.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 69, 196, 255),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
                child:
                    TextBox(fieldText: fieldText)), //Center(child: TextBox()),
          ),
          Row(
            // Buttons
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Add the text to speech functionality
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
          children: const [
            SizedBox(
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
            ListTile(leading: Icon(Icons.home), title: Text("Home")),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
            )
          ],
        ));
  }
}

// class TextBox extends StatelessWidget {
//   const TextBox({
//     super.key,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox(
//       width: 1000,
//       height: 250,
//       child: TextField(
//         cursorColor: Colors.black,
//         style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 60),
//         maxLines: 5,
//         decoration: InputDecoration(
//           filled: true,
//           hintText: "Enter Text Here",
//           fillColor: Color.fromARGB(255, 255, 255, 255),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//           ),
//         ),
//       ),
//     );
//   }
// }
