class DisplayStatus {
  final int idStatus;
  final int idContent;
  final String status;

  DisplayStatus({
    required this.idStatus,
    required this.idContent,
    required this.status,
  });

  factory DisplayStatus.fromJson(Map<String, dynamic> json) {
    return DisplayStatus(
      idStatus: json['id_status'],
      idContent: json['id_content'],
      status: json['status'],
    );
  }
}