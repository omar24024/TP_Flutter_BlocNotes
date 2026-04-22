// lib/pages/detail_page.dart
//
// PARTIE 2 — Refactorisée avec Provider.
// • Lit la note depuis NoteService (se synchronise automatiquement).
// • Suppression et modification passent par le service.
// • Plus besoin de retourner 'deleted' / note_modifiée à HomePage.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';

class DetailNotePage extends StatelessWidget {
  /// On passe l'id plutôt que la note entière pour toujours lire l'état frais.
  final Note note;

  const DetailNotePage({super.key, required this.note});

  // ─────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  String _formatDateComplete(DateTime date) {
    const jours = [
      '', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi', 'dimanche'
    ];
    const mois = [
      '', 'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${jours[date.weekday]} ${date.day} ${mois[date.month]} ${date.year} à $h:$m';
  }

  // ─────────────────────────────────────────────
  //  Actions
  // ─────────────────────────────────────────────

  void _ouvrirModification(BuildContext context, Note noteActuelle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNotePage(noteExistante: noteActuelle),
      ),
    );
  }

  Future<void> _confirmerSuppression(
      BuildContext context, Note noteActuelle) async {
    final bool? confirme = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer la note ?'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer « ${noteActuelle.titre} » ?\nCette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true && context.mounted) {
      // Suppression dans le service — HomePage se reconstruit tout seul
      context.read<NoteService>().supprimerNote(noteActuelle.id);
      Navigator.pop(context);
    }
  }

  // ─────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Consumer<NoteService> pour refléter les modifications en temps réel.
    // On relit la note par id au cas où elle aurait été modifiée.
    return Consumer<NoteService>(
      builder: (context, service, _) {
        // Si la note a été supprimée depuis une autre route, on revient.
        final noteActuelle = service.trouverParId(note.id) ?? note;

        final couleur = _hexToColor(noteActuelle.couleur);
        final estCouleurSombre = couleur.computeLuminance() < 0.5;
        final couleurTexteAppBar =
            estCouleurSombre ? Colors.white : Colors.black87;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            backgroundColor: couleur,
            foregroundColor: couleurTexteAppBar,
            elevation: 0,
            title: Text(
              'Détail',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: couleurTexteAppBar),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: couleurTexteAppBar),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    _ouvrirModification(context, noteActuelle),
                icon: Icon(Icons.edit, color: couleurTexteAppBar),
                tooltip: 'Modifier',
              ),
              IconButton(
                onPressed: () =>
                    _confirmerSuppression(context, noteActuelle),
                icon: Icon(Icons.delete_outline,
                    color: couleurTexteAppBar),
                tooltip: 'Supprimer',
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Bandeau de couleur ──────────────────────
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: couleur,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Titre ───────────────────────────────────
                Text(
                  noteActuelle.titre,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),

                // ── Date de création ────────────────────────
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 6),
                    Text(
                      'Créée le ${_formatDateComplete(noteActuelle.dateCreation)}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),

                // ── Date de modification ────────────────────
                if (noteActuelle.dateModification != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.edit_calendar,
                          size: 14, color: Colors.grey[400]),
                      const SizedBox(width: 6),
                      Text(
                        'Modifiée le ${_formatDateComplete(noteActuelle.dateModification!)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // ── Contenu complet ─────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Text(
                    noteActuelle.contenu.isEmpty
                        ? '(Aucun contenu)'
                        : noteActuelle.contenu,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: noteActuelle.contenu.isEmpty
                          ? Colors.grey[400]
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
