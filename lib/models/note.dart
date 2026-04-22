class Note {
  final String id;
  String titre;
  String contenu;
  String couleur;
  final DateTime dateCreation;
  DateTime? dateModification;

  Note({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.couleur,
    required this.dateCreation,
    this.dateModification,
  });

  /// Crée une copie modifiée de la note
  Note copyWith({
    String? titre,
    String? contenu,
    String? couleur,
    DateTime? dateModification,
  }) {
    return Note(
      id: id,
      titre: titre ?? this.titre,
      contenu: contenu ?? this.contenu,
      couleur: couleur ?? this.couleur,
      dateCreation: dateCreation,
      dateModification: dateModification ?? this.dateModification,
    );
  }
}
