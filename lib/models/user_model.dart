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
    id:        int.parse(json['id'].toString()),          // handles "1" or 1
    name:      json['name'].toString(),
    email:     json['email'].toString(),
    signature: json['signature']?.toString(),             // nullable safe
    createdAt: json['created_at']?.toString(),            // nullable safe
  );

  Map<String, dynamic> toJson() => {
    'id':         id,
    'name':       name,
    'email':      email,
    'signature':  signature,
    'created_at': createdAt,
  };

  UserModel copyWith({String? name, String? signature}) => UserModel(
    id:        id,
    email:     email,
    createdAt: createdAt,
    name:      name      ?? this.name,
    signature: signature ?? this.signature,
  );
}
