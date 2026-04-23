import 'package:flutter/foundation.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  final List<Note> _notes = [];
  String _search = '';

  // ── GETTERS ──

  List<Note> get notes => _notes;

  List<Note> get notesFiltrees {
    if (_search.isEmpty) return _notes;

    return _notes.where((n) {
      return n.titre.toLowerCase().contains(_search.toLowerCase()) ||
          n.contenu.toLowerCase().contains(_search.toLowerCase());
    }).toList();
  }

  int get nombreNotes => _notes.length;

  String get recherche => _search;

  // ── CRUD ──

  void ajouterNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  void modifierNote(Note note) {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i != -1) {
      _notes[i] = note;
      notifyListeners();
    }
  }

  void supprimerNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  Note? trouverParId(String id) {
    for (var n in _notes) {
      if (n.id == id) return n;
    }
    return null;
  }

  // ── SEARCH ──

  void changerRecherche(String v) {
    _search = v;
    notifyListeners();
  }

  void effacerRecherche() {
    _search = '';
    notifyListeners();
  }
}
