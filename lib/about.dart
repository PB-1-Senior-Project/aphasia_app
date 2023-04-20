import 'package:flutter/material.dart';
import 'stream.dart';

class AboutPage extends StatelessWidget {
  const AboutPage ({
    super.key,
  });

  @override
  Widget build (BuildContext context) {
    return Scaffold (
      appBar: AppBar (
        title: const Text("About"),
      ),
      body: RichText (
        text: const TextSpan (
          text: "The primary goal of the Aphasia App is to improve the speech production and day-to-day activities of people afflicted with aphasia.",
          style: TextStyle (fontSize: 20, color: Colors.grey),        
        )
      )
    );
  }
}