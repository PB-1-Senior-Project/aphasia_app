import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
            child: TextField(
          cursorColor: Colors.black,
          style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.blueAccent,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
            ),
          ),
        )),
      ),
    );
  }
}
