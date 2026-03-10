class UserModel {
  final int id;
  final String name;
  final String email;
  final String? signature;
  final String? createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.signature,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: int.parse(json['id'].toString()), // handles both "1" and 1
        name: json['name'] as String,
        email: json['email'] as String,
        signature: json['signature'] as String?,
        createdAt: json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'signature': signature,
        'created_at': createdAt,
      };

  UserModel copyWith({String? name, String? signature}) => UserModel(
        id: id,
        email: email,
        name: name ?? this.name,
        signature: signature ?? this.signature,
        createdAt: createdAt,
      );
}
