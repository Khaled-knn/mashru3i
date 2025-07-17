import 'dart:convert';

class CreatorProfile {
  final int id;
  final int professionId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String storeName;
  final String? profileImage;
  final String? coverImage;
  final String status;
  final String createdAt;
  final double tokens;
  final double deliveryValue;
  final double income;
  final Map<String, dynamic>? availability;
  final List<String> paymentMethod;

  CreatorProfile({
    required this.id,
    required this.professionId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.storeName,
    this.profileImage,
    this.coverImage,
    required this.status,
    required this.createdAt,
    required this.tokens,
    required this.deliveryValue,
    this.availability,
    required this.paymentMethod,
    required this.income,
  });

  factory CreatorProfile.fromJson(Map<String, dynamic> json) {
    final parsedTokens = _parseDouble(json['tokens']);
    final parsedDeliveryValue = _parseDouble(json['deliveryValue']);
    final parsedIncome = _parseDouble(json['monthly_income']);

    final availability = _parseAvailability(json['availability']);
    final paymentMethod = _parsePaymentMethod(json['payment_method']);

    return CreatorProfile(
      id: json['id'] as int,
      professionId: json['profession_id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      storeName: json['store_name'] as String,
      profileImage: json['profile_image'] as String?,
      coverImage: json['cover_photo'] as String?,
      status: json['status'] as String,
      createdAt: json['created_at'] as String,
      tokens: parsedTokens,
      deliveryValue: parsedDeliveryValue,
      income: parsedIncome,
      availability: availability,
      paymentMethod: paymentMethod,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Map<String, dynamic>? _parseAvailability(dynamic availabilityData) {
    if (availabilityData == null) return null;

    try {
      if (availabilityData is String) {

        availabilityData = jsonDecode(availabilityData);
      }

      if (availabilityData is Map) {

        return availabilityData.cast<String, dynamic>();
      }

      if (availabilityData is List && availabilityData.isNotEmpty) {

        return availabilityData.first.cast<String, dynamic>();
      }
    } catch (e) {
      print('Error parsing availability: $e');
    }

    return null;
  }

  static List<String> _parsePaymentMethod(dynamic paymentData) {
    if (paymentData == null) return [];

    try {
      if (paymentData is String) {

        paymentData = jsonDecode(paymentData);
      }

      if (paymentData is List) {

        return paymentData.map((e) => e.toString()).toList();
      }

      if (paymentData is Map) {

        return paymentData.values.map((e) => e.toString()).toList();
      }
    } catch (e) {
      print('Error parsing payment method: $e');
    }

    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profession_id': professionId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'store_name': storeName,
      'profile_image': profileImage,
      'cover_photo': coverImage,
      'status': status,
      'createdAt': createdAt,
      'tokens': tokens,
      'deliveryValue': deliveryValue,
      'monthly_income': income,
      'availability': availability != null ? jsonEncode(availability) : null,
      'payment_method': jsonEncode(paymentMethod),
    };
  }

  CreatorProfile copyWith({
    int? id,
    int? professionId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? storeName,
    String? profileImage,
    String? coverImage,
    String? status,
    String? createdAt,
    double? tokens,
    double? income,
    double? deliveryValue,
    Map<String, dynamic>? availability,
    List<String>? paymentMethod,

  }) {
    return CreatorProfile(
      id: id ?? this.id,
      professionId: professionId ?? this.professionId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      storeName: storeName ?? this.storeName,
      profileImage: profileImage ?? this.profileImage,
      coverImage: coverImage ?? this.coverImage,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      tokens: tokens ?? this.tokens,
      income: income ?? this.income,
      deliveryValue: deliveryValue ?? this.deliveryValue,
      availability: availability ?? this.availability,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }
}