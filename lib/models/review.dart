class Review {
  final int idReview;
  final int idContent;
  final int? idUser;        // ← nullable
  final int score;
  final String? comment;
  final String date;

  Review({
    required this.idReview,
    required this.idContent,
    this.idUser,            // ← opcional
    required this.score,
    this.comment,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      idReview: json['id_review'],
      idContent: json['id_content'],
      idUser: json['id_user'],
      score: json['score'],
      comment: json['comment'],
      date: json['date'],
    );
  }
}