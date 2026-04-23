import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import 'create_page.dart';
import 'detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _openCreate(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateNotePage()),
    );
  }

  void _openDetail(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailNotePage(note: note)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Notes'),
        actions: [
          Consumer<NoteService>(
            builder: (_, s, __) => Center(
              child: Text('${s.nombreNotes}'),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              onChanged: (v) => context.read<NoteService>().changerRecherche(v),
              decoration: const InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // LIST
          Expanded(
            child: Consumer<NoteService>(
              builder: (context, service, _) {
                final notes = service.notesFiltrees;

                if (notes.isEmpty) {
                  return const Center(child: Text('Aucune note'));
                }

                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (_, i) {
                    final n = notes[i];

                    return ListTile(
                      title: Text(n.titre),
                      subtitle: Text(
                        n.contenu,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _openDetail(context, n),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreate(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
