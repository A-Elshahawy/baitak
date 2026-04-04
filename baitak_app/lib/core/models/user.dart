class User {
  const User({
    required this.id,
    required this.name,
    this.email,
    required this.commissionRate,
  });

  final int id;
  final String name;
  final String? email;
  final double commissionRate;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String?,
        commissionRate: (json['commission_rate'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'commission_rate': commissionRate,
      };

  User copyWith({
    int? id,
    String? name,
    String? email,
    double? commissionRate,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      commissionRate: commissionRate ?? this.commissionRate,
    );
  }
}
