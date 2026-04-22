// lib/pages/home_page.dart
//
// PARTIE 2 — Refactorisée avec Provider.
// • Plus de List<Note> _notes locale.
// • Consumer<NoteService> pour reconstruire la liste automatiquement.
// • Barre de recherche temps réel (filtrage via NoteService).
// • Les navigations ne retournent plus de valeur — le service notifie.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formatDate(DateTime date) {
    const mois = [
      '', 'jan.', 'fév.', 'mar.', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sep.', 'oct.', 'nov.', 'déc.'
    ];
    return '${date.day} ${mois[date.month]} ${date.year}';
  }

  // ─────────────────────────────────────────────
  //  Navigation
  // ─────────────────────────────────────────────

  /// Ouvre la page de création.
  /// La note créée est ajoutée directement dans NoteService — pas de retour.
  void _ouvrirCreation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateNotePage()),
    );
  }

  /// Ouvre le détail d'une note.
  void _ouvrirDetail(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailNotePage(note: note)),
    );
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Mes Notes',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        elevation: 0,
        // Compteur de notes dans l'AppBar
        actions: [
          Consumer<NoteService>(
            builder: (_, service, __) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${service.nombreNotes}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Barre de recherche ─────────────────────────
          _SearchBar(),
          // ── Liste ou état vide ─────────────────────────
          Expanded(
            child: Consumer<NoteService>(
              builder: (context, service, _) {
                final notes = service.notesFiltrees;

                if (service.nombreNotes == 0) {
                  return _buildEmptyState(recherche: false);
                }
                if (notes.isEmpty) {
                  return _buildEmptyState(recherche: true);
                }
                return _buildNotesList(context, notes);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _ouvrirCreation(context),
        backgroundColor: const Color(0xFF5C6BC0),
        foregroundColor: Colors.white,
        tooltip: 'Nouvelle note',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Widgets internes
  // ─────────────────────────────────────────────

  Widget _buildEmptyState({required bool recherche}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            recherche ? Icons.search_off : Icons.note_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            recherche ? 'Aucun résultat' : 'Aucune note',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            recherche
                ? 'Essayez un autre mot-clé'
                : 'Appuyez sur + pour créer votre première note',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(BuildContext context, List<Note> notes) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        final couleur = _hexToColor(note.couleur);

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: InkWell(
            onTap: () => _ouvrirDetail(context, note),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border(
                  left: BorderSide(color: couleur, width: 5),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.titre,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (note.contenu.isNotEmpty)
                    Text(
                      note.contenu.length > 30
                          ? '${note.contenu.substring(0, 30)}…'
                          : note.contenu,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(note.dateCreation),
                        style:
                            TextStyle(fontSize: 11, color: Colors.grey[400]),
                      ),
                      Icon(Icons.arrow_forward_ios,
                          size: 12, color: Colors.grey[400]),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widget Barre de recherche (StatefulWidget local)
// ─────────────────────────────────────────────────────────────────────────────

/// Barre de recherche qui met à jour NoteService en temps réel.
/// Séparée en StatefulWidget pour gérer le TextEditingController proprement.
class _SearchBar extends StatefulWidget {
  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF5C6BC0),
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: TextField(
        controller: _controller,
        onChanged: (val) =>
            context.read<NoteService>().changerRecherche(val),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher une note…',
          hintStyle: const TextStyle(color: Colors.white60),
          prefixIcon:
              const Icon(Icons.search, color: Colors.white70),
          suffixIcon: Consumer<NoteService>(
            builder: (_, service, __) => service.recherche.isNotEmpty
                ? IconButton(
                    icon:
                        const Icon(Icons.clear, color: Colors.white70),
                    onPressed: () {
                      _controller.clear();
                      service.effacerRecherche();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: Colors.white12,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}
