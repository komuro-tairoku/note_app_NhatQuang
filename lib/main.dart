import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'database/db_helper.dart';
import 'providers/provider_note.dart';
import 'screens/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void dispose() {
    DatabaseHelper.instance.close(); // gọi khi app thoát
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NoteProvider()..loadNotes(),
      child: MaterialApp(
        title: 'Note App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomePage(),
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}
