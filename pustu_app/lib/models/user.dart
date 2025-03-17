class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? deviceToken;
  final String? token; // API token for authentication

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.deviceToken,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      deviceToken: json['device_token'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'device_token': deviceToken,
      'token': token,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isPetugas => role == 'petugas';
  bool get isPatient => role == 'patient';

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? deviceToken,
    String? token,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      deviceToken: deviceToken ?? this.deviceToken,
      token: token ?? this.token,
    );
  }
}
