import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../services/note_service.dart';

class CreateNotePage extends StatefulWidget {
  final Note? noteExistante;

  const CreateNotePage({super.key, this.noteExistante});

  @override
  State<CreateNotePage> createState() => _CreateNotePageState();
}

class _CreateNotePageState extends State<CreateNotePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titreCtrl;
  late TextEditingController contenuCtrl;

  String couleur = '#FFE082';

  final List<String> colors = [
    '#FFE082',
    '#A5D6A7',
    '#90CAF9',
    '#F48FB1',
  ];

  bool get isEdit => widget.noteExistante != null;

  @override
  void initState() {
    super.initState();
    titreCtrl = TextEditingController(text: widget.noteExistante?.titre ?? '');
    contenuCtrl =
        TextEditingController(text: widget.noteExistante?.contenu ?? '');
    couleur = widget.noteExistante?.couleur ?? colors[0];
  }

  @override
  void dispose() {
    titreCtrl.dispose();
    contenuCtrl.dispose();
    super.dispose();
  }

  void save() {
    if (!_formKey.currentState!.validate()) return;

    final service = context.read<NoteService>();

    if (isEdit) {
      service.modifierNote(
        widget.noteExistante!.copyWith(
          titre: titreCtrl.text,
          contenu: contenuCtrl.text,
          couleur: couleur,
          dateModification: DateTime.now(),
        ),
      );
    } else {
      service.ajouterNote(
        Note(
          id: DateTime.now().toString(),
          titre: titreCtrl.text,
          contenu: contenuCtrl.text,
          couleur: couleur,
          dateCreation: DateTime.now(),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier' : 'Créer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: save,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Champ obligatoire' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: contenuCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Contenu',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: colors.map((c) {
                  final selected = c == couleur;
                  return GestureDetector(
                    onTap: () => setState(() => couleur = c),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color:
                            Color(int.parse('FF${c.substring(1)}', radix: 16)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: save,
                  child: Text(isEdit ? 'Mettre à jour' : 'Créer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
