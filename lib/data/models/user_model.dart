class UserModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  int points;
  final bool isVerified;

  final String? city;
  final String? street;
  final String? country;

  final String? verificationToken;
  final String? resetPasswordToken;
  final String? provider;
  final String? providerId;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.points,
    required this.isVerified,
    this.city,
    this.street,
    this.country,
    this.verificationToken,
    this.resetPasswordToken,
    this.provider,
    this.providerId,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int?,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      points: json['points'] as int? ?? 0,
      isVerified: (json['is_verified'] as int) == 1,
      city: json['city'] as String?,
      street: json['street'] as String?,
      country: json['country'] as String?, // 👈  استقبلنا قيمة الـ 'country' من الـ JSON هنا
      verificationToken: json['verification_token'] as String?,
      resetPasswordToken: json['reset_password_token'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'points': points,
      'is_verified': isVerified ? 1 : 0,
      'city': city,
      'street': street,
      'country': country,
      'verification_token': verificationToken,
      'reset_password_token': resetPasswordToken,
      'provider': provider,
      'provider_id': providerId,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  UserModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    int? points,
    bool? isVerified,
    String? city,
    String? street,
    String? country,
    String? verificationToken,
    String? resetPasswordToken,
    String? provider,
    String? providerId,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      points: points ?? this.points,
      isVerified: isVerified ?? this.isVerified,
      city: city ?? this.city,
      street: street ?? this.street,
      country: country ?? this.country,
      verificationToken: verificationToken ?? this.verificationToken,
      resetPasswordToken: resetPasswordToken ?? this.resetPasswordToken,
      provider: provider ?? this.provider,
      providerId: providerId ?? this.providerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}