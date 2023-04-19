import 'package:flutter/material.dart';
import 'package:volume_control/volume_control.dart';
import 'stream.dart' as stream;

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

  Future<void> initVolumeState () async {
    if (!mounted) return;

    _val = await VolumeControl.volume;
    setState(() {
      
    });
  }

  double _val = 0.5;
  String _theme = 'light';
  String _fontSize = 'med';

  @override
  Widget build (BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: const Text ('Settings')),
      body: Column(
        children: [
          SettingsChanger( //package volume_watcher can be added to make the slider automatically move when device's volume is changed
            settingName: 'Volume',
            settingWidget: Slider(
              value: _val,
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: (value) {
                _val = value;
                VolumeControl.setVolume(value);
                setState(() { });
              }
            ),
          ),
          SettingsChanger(
            settingName: 'Text Size',
            padding: 50,
            settingWidget: DropdownButton (
              value: _fontSize,
              items: [
                DropdownMenuItem (value: 'lar', child: Text ('Large', style: stream.wordTheme.textTheme.bodyMedium)),
                DropdownMenuItem (value: 'med', child: Text ('Medium', style: stream.wordTheme.textTheme.bodyMedium)),
                DropdownMenuItem (value: 'sma', child: Text ('Small', style: stream.wordTheme.textTheme.bodyMedium)),              
              ],
              onChanged: (string) {
                if (string == null) return;
                if (string == 'sma') {
                  stream.current = stream.wordTheme.textTheme.bodySmall;
                  _fontSize = string;
                }
                else if (string == 'med') {
                  stream.current = stream.wordTheme.textTheme.bodyMedium;
                  _fontSize = string;
                }
                else {
                  stream.current = stream.wordTheme.textTheme.bodyLarge;
                  _fontSize = string;
                }

                setState(() {
                  
                });
              },
            ),
          ),
          SettingsChanger(
            settingName: 'Text-to-Speech Speed',
            settingWidget: Slider(
              value: 0.5,
              onChanged: (double value) {},
            ),
          ),
          SettingsChanger(
            settingName: 'Theme',
            padding: 50,
            settingWidget: DropdownButton <String> (
              value: _theme,
              items: [
                DropdownMenuItem(value: 'light', child: Text ('Light')),
                DropdownMenuItem(value: 'dark', child: Text ('Dark')),
              ],
              onChanged: (string) {
                if (string == 'light') {
                  stream.currentTheme.add(stream.lightTheme);
                  _theme = 'light';
                }
                else { 
                  stream.currentTheme.add(stream.darkTheme); 
                  _theme = 'dark';
                }
                
                setState(() {
                  
                });
              },
            ),
          ),
        ]
      )
    );
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
  Widget build (BuildContext context) {
    return Row (
      children: [
        Text(widget.settingName, style: stream.wordTheme.textTheme.bodyMedium),
        SizedBox(width: widget.padding),
        widget.settingWidget,
      ],
    );
  }
}


