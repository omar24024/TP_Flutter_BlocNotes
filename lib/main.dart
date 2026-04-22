// lib/main.dart
//
// PARTIE 2 — Provider injecté à la racine de l'arbre de widgets.
// NoteService est créé ici et disponible dans tout l'arbre via context.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/note_service.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    // ChangeNotifierProvider crée NoteService et le détruit avec l'app.
    ChangeNotifierProvider(
      create: (_) => NoteService(),
      child: const BlocNotesApp(),
    ),
  );
}

class BlocNotesApp extends StatelessWidget {
  const BlocNotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5C6BC0),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}
