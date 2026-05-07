class AppUser {
  final String? id;
  final String email;
  final String fullName;
  final String? role;
  final double? growthPoints;
  final DateTime? createdDate;

  AppUser({
    this.id,
    required this.email,
    required this.fullName,
    this.role,
    this.growthPoints,
    this.createdDate,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'],
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'],
      growthPoints: json['growth_points']?.toDouble(),
      createdDate: json['created_date'] != null
          ? DateTime.tryParse(json['created_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'full_name': fullName,
      'role': role,
      'growth_points': growthPoints,
    };
  }
}
