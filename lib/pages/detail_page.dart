import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';

class DetailNotePage extends StatelessWidget {
  final Note note;

  const DetailNotePage({super.key, required this.note});

  void _edit(BuildContext context, Note n) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNotePage(noteExistante: n),
      ),
    );
  }

  void _delete(BuildContext context, Note n) {
    context.read<NoteService>().supprimerNote(n.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteService>(
      builder: (context, service, _) {
        final n = service.trouverParId(note.id) ?? note;

        return Scaffold(
          appBar: AppBar(
            title: Text(n.titre),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _edit(context, n),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _delete(context, n),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  width: double.infinity,
                  color: Colors.blue,
                ),
                const SizedBox(height: 15),
                Text(
                  n.titre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  n.contenu.isEmpty ? 'Aucun contenu' : n.contenu,
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                Text(
                  'Créée: ${n.dateCreation}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                if (n.dateModification != null)
                  Text(
                    'Modifiée: ${n.dateModification}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
