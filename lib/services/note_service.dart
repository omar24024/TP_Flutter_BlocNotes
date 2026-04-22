// lib/services/note_service.dart
//
// PARTIE 2 — Provider & Gestion d'État Global
// NoteService est un ChangeNotifier qui centralise toute la logique métier.
// Il remplace les List<Note> _notes locales dispersées dans les widgets.

import 'package:flutter/foundation.dart';
import '../models/note.dart';

class NoteService extends ChangeNotifier {
  // ─────────────────────────────────────────────
  //  État interne
  // ─────────────────────────────────────────────

  final List<Note> _notes = [];

  /// Texte de recherche courant (filtrage en temps réel)
  String _recherche = '';

  // ─────────────────────────────────────────────
  //  Getters publics
  // ─────────────────────────────────────────────

  /// Toutes les notes (non filtrées)
  List<Note> get notes => List.unmodifiable(_notes);

  /// Notes filtrées selon [_recherche]
  List<Note> get notesFiltrees {
    if (_recherche.isEmpty) return List.unmodifiable(_notes);
    final q = _recherche.toLowerCase();
    return _notes
        .where((n) =>
            n.titre.toLowerCase().contains(q) ||
            n.contenu.toLowerCase().contains(q))
        .toList();
  }

  /// Texte de recherche courant
  String get recherche => _recherche;

  /// Nombre total de notes
  int get nombreNotes => _notes.length;

  // ─────────────────────────────────────────────
  //  Commandes CRUD
  // ─────────────────────────────────────────────

  /// Ajoute une nouvelle note et notifie les listeners.
  void ajouterNote(Note note) {
    _notes.add(note);
    notifyListeners();
  }

  /// Remplace la note ayant le même [id] et notifie les listeners.
  void modifierNote(Note noteModifiee) {
    final index = _notes.indexWhere((n) => n.id == noteModifiee.id);
    if (index != -1) {
      _notes[index] = noteModifiee;
      notifyListeners();
    }
  }

  /// Supprime la note avec [id] et notifie les listeners.
  void supprimerNote(String id) {
    _notes.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  /// Retourne la note avec [id], ou null si introuvable.
  Note? trouverParId(String id) {
    try {
      return _notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  //  Recherche / Filtrage
  // ─────────────────────────────────────────────

  /// Met à jour le filtre de recherche et notifie les listeners.
  void changerRecherche(String valeur) {
    _recherche = valeur;
    notifyListeners();
  }

  /// Réinitialise la recherche.
  void effacerRecherche() {
    _recherche = '';
    notifyListeners();
  }
}
