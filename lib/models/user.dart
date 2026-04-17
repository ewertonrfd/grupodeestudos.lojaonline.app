class User {
  final int id;
  final String name;
  final String email;
  final String type; // 'USER' or 'LOJISTA'

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: json['tipo'] ?? json['type'] ?? 'USER',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'tipo': type,
    };
  }

  bool get isLojista => type == 'LOJISTA';
}
