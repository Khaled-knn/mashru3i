class AddressModel {
  final int ? creatorId;
  final String street;
  final String city;
  final String country;

  AddressModel({
    required this.creatorId,
    required this.street,
    required this.city,
    required this.country,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      creatorId: json['creator_id'],
      street: json['street'],
      city: json['city'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'creator_id': creatorId,
      'street': street,
      'city': city,
      'country': country,
    };
  }
}
