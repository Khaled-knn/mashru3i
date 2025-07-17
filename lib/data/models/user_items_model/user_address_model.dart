class UserAddressModel {
  final String city;
  final String street;

  UserAddressModel({required this.city, required this.street});

  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      city: json['city'] ?? '',
      street: json['street'] ?? '',
    );
  }
}
