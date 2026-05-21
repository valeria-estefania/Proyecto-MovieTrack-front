class Content {
  final int idContent;
  final int tmdbId;
  final String title;
  final String? description;
  final String type;
  final String? releaseDate;
  final String? posterUrl;
  final double? rating;
  final String? backdropUrl;

  Content({
    required this.idContent,
    required this.tmdbId,
    required this.title,
    this.description,
    required this.type,
    this.releaseDate,
    this.posterUrl,
    this.rating,
    this.backdropUrl,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      idContent: json['id_content'],
      tmdbId: json['tmdb_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      releaseDate: json['release_date'],
      posterUrl: json['poster_url'],
      rating: json['rating']?.toDouble(),
      backdropUrl: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w1280${json['backdrop_path']}'
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_content': idContent,
      'tmdb_id': tmdbId,
      'title': title,
      'description': description,
      'type': type,
      'release_date': releaseDate,
      'poster_url': posterUrl,
      'rating': rating,
    };
  }
}