class User {
  final int idUser;
  final String name;
  final String email;
  final String fechaRegistro;
  final String role;

  User({
    required this.idUser,
    required this.name,
    required this.email,
    required this.fechaRegistro,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idUser: json['id_user'],
      name: json['name'],
      email: json['email'],
      fechaRegistro: json['fecha_registro'],
      role: json['role'],
    );
  }
}