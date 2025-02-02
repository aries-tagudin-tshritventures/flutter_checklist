import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_checklist/checklist.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final lines = List.generate(
    5,
    (index) => (text: 'Line ${index + 1}', toggled: false),
  );

  void onChanged(List<ChecklistLine> lines) {
    log(lines.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: Locale('en'),
      localizationsDelegates: [
        ...ChecklistLocalizations.localizationsDelegates,
      ],
      supportedLocales: [
        ...ChecklistLocalizations.supportedLocales,
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('flutter_checklist example'),
        ),
        body: Builder(
          builder: (context) {
            return Checklist(
              lines: lines,
              onChanged: onChanged,
            );
          },
        ),
      ),
    );
  }
}
