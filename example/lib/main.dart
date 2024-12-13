import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_checklist/checklist.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Display the application behind the system's notifications bar and navigation bar
  // See https://github.com/flutter/flutter/issues/40974
  // See https://github.com/flutter/flutter/issues/34678
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
    ),
  );

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
