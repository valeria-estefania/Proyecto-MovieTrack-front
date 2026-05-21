class Favorite {
  final int idFavorite;
  final int idContent;
  final String dateAdded;

  Favorite({
    required this.idFavorite,
    required this.idContent,
    required this.dateAdded,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      idFavorite: json['id_favorite'],
      idContent: json['id_content'],
      dateAdded: json['date_added'],
    );
  }
}