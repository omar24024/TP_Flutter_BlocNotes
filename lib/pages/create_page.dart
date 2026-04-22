// lib/pages/create_page.dart
//
// PARTIE 2 — Refactorisée avec Provider.
// • Appelle NoteService.ajouterNote() ou NoteService.modifierNote()
//   directement depuis le service — plus de Navigator.pop(context, note).
// • La HomePage se reconstruit automatiquement via Consumer.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class CreateNotePage extends StatefulWidget {
  /// Si [noteExistante] est fournie → mode modification, sinon → mode création
  final Note? noteExistante;

  const CreateNotePage({super.key, this.noteExistante});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  late TextEditingController _titreController;
  late TextEditingController _contenuController;
  late String _couleurSelectionnee;

  static const List<String> _palette = [
    '#FFE082', // Jaune
    '#A5D6A7', // Vert
    '#90CAF9', // Bleu
    '#F48FB1', // Rose
    '#CE93D8', // Violet
    '#FFCC80', // Orange
  ];

  final _formKey = GlobalKey<FormState>();

  bool get _estModeModification => widget.noteExistante != null;

  @override
  void initState() {
    super.initState();
    _titreController =
        TextEditingController(text: widget.noteExistante?.titre ?? '');
    _contenuController =
        TextEditingController(text: widget.noteExistante?.contenu ?? '');
    _couleurSelectionnee =
        widget.noteExistante?.couleur ?? _palette[0];
  }

  @override
  void dispose() {
    _titreController.dispose();
    _contenuController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  Sauvegarder via NoteService
  // ─────────────────────────────────────────────
  void _sauvegarder() {
    if (!_formKey.currentState!.validate()) return;

    final service = context.read<NoteService>();

    if (_estModeModification) {
      // Mode modification : mise à jour via le service
      final noteModifiee = widget.noteExistante!.copyWith(
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurSelectionnee,
        dateModification: DateTime.now(),
      );
      service.modifierNote(noteModifiee);
    } else {
      // Mode création : nouvelle note ajoutée via le service
      final nouvelleNote = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        titre: _titreController.text.trim(),
        contenu: _contenuController.text.trim(),
        couleur: _couleurSelectionnee,
        dateCreation: DateTime.now(),
      );
      service.ajouterNote(nouvelleNote);
    }

    // Retour simple — plus besoin de passer la note
    Navigator.pop(context);
  }

  // ─────────────────────────────────────────────
  //  Interface
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          _estModeModification ? 'Modifier la note' : 'Nouvelle note',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _sauvegarder,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Sauvegarder',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Titre ────────────────────────────────────
              _buildSectionLabel('Titre'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _titreController,
                maxLength: 60,
                decoration: _inputDecoration(
                    hint: 'Titre de la note…', icon: Icons.title),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Le titre ne peut pas être vide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // ── Contenu ──────────────────────────────────
              _buildSectionLabel('Contenu'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _contenuController,
                minLines: 4,
                maxLines: 10,
                decoration: _inputDecoration(
                    hint: 'Écrivez votre note ici…', icon: Icons.notes),
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),

              // ── Couleur ──────────────────────────────────
              _buildSectionLabel('Couleur'),
              const SizedBox(height: 10),
              _buildColorPicker(),
              const SizedBox(height: 30),

              // ── Bouton principal ─────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _sauvegarder,
                  icon: const Icon(Icons.save),
                  label: Text(
                    _estModeModification
                        ? 'Mettre à jour'
                        : 'Créer la note',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String texte) {
    return Text(
      texte,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5C6BC0),
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF5C6BC0)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Row(
      children: _palette.map((hex) {
        final couleur = _hexToColor(hex);
        final estSelectionne = hex == _couleurSelectionnee;

        return GestureDetector(
          onTap: () => setState(() => _couleurSelectionnee = hex),
          child: Container(
            margin: const EdgeInsets.only(right: 12),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: couleur,
              shape: BoxShape.circle,
              border: Border.all(
                color: estSelectionne
                    ? const Color(0xFF5C6BC0)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: estSelectionne
                  ? [
                      const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2))
                    ]
                  : [],
            ),
            child: estSelectionne
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : null,
          ),
        );
      }).toList(),
    );
  }

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
