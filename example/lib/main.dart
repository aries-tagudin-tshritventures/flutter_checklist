import 'package:checklist/checklist.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Example app.
class MyApp extends StatefulWidget {
  /// Example app.
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void onChange(List<ChecklistValue> checklistValues) {
    print(checklistValues);
  }

  @override
  Widget build(BuildContext context) {
    List<ChecklistValue> checklistLines = List.generate(
        10, (i) => (text: 'Line dddddddddddddddddddddddddddddddddddddddddddddddddddd a $i', toggled: false));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('checklist example app'),
        ),
        body: Builder(
          builder: (context) {
            return Checklist(
              lines: checklistLines,
              onChange: onChange,
            );
          },
        ),
      ),
    );
  }
}
