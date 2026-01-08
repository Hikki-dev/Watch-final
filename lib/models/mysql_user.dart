class MysqlUser {
  final int id;
  final String name;
  final String email;
  final String role; // 'admin', 'customer', etc.
  final String? createdAt;

  MysqlUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory MysqlUser.fromJson(Map<String, dynamic> json) {
    return MysqlUser(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? 'Unknown Name',
      email: json['email'] ?? 'No Email',
      role: json['role'] ?? 'customer',
      createdAt: json['created_at'],
    );
  }
}
