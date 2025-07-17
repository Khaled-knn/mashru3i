import 'dart:convert';
import 'models/user_items_model/CreatorAvailability.dart';

import 'package:mashrou3i/data/creatorsItems.dart'; // لتجنب تكرار CreatorOffer

class CreatorItem {
  final int id;
  final String fullName;
  final String profileImage;
  final String? coverPhoto;
  final String storeName;
  final double deliveryValue;
  final double rate;
  final int rateCount;
  final CreatorAddress? address;
  final List<CreatorOffer> offers;
  final List<CreatorPaymentMethod> paymentMethods;
  final List<CreatorAvailability> availability;

  CreatorItem({
    required this.id,
    required this.fullName,
    required this.profileImage,
    required this.coverPhoto,
    required this.storeName,
    required this.deliveryValue,
    required this.offers,
    required this.paymentMethods,
    required this.availability,
    required this.rate,
    this.address,
    required this.rateCount,
  });

  factory CreatorItem.fromJson(Map<String, dynamic> json) {
    return CreatorItem(
      id: _parseInt(json['id']),
      fullName: json['full_name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString() ?? '',
      coverPhoto: json['cover_photo']?.toString(),
      storeName: json['store_name']?.toString() ?? '',
      deliveryValue: _parseDouble(json['deliveryValue']),
      offers: (json['offers'] as List<dynamic>?)
          ?.map((e) => CreatorOffer.fromJson(e))
          .toList() ??
          [],
      paymentMethods: (json['payment_methods'] as List<dynamic>?)
          ?.map((e) => CreatorPaymentMethod.fromJson(e))
          .toList() ??
          [],
      availability: (json['availability'] as List<dynamic>?)
          ?.map((e) => CreatorAvailability.fromJson(e))
          .toList() ??
          [],
      rate: _parseDouble(json['rate']),
      rateCount: _parseInt(json['rate_count']),
      address: json['address'] != null
          ? CreatorAddress.fromJson(json['address'])
          : null,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'profileImage': profileImage,
      'coverPhoto': coverPhoto,
      'storeName': storeName,
      'deliveryValue': deliveryValue,
      'rate': rate,
      'rateCount': rateCount,

      'address': address != null ? jsonEncode(address!.toJson()) : null,

      'offers': jsonEncode(offers.map((e) => e.toJson()).toList()),

      'paymentMethods': jsonEncode(paymentMethods.map((e) => e.toJson()).toList()),

      'availability': jsonEncode(availability.map((e) => e.toJson()).toList()),
    };
  }


  factory CreatorItem.fromMap(Map<String, dynamic> map) {

    final String? addressJson = map['address'] as String?;
    final String? offersJson = map['offers'] as String?;
    final String? paymentMethodsJson = map['paymentMethods'] as String?;
    final String? availabilityJson = map['availability'] as String?;

    return CreatorItem(
      id: map['id'],
      fullName: map['fullName'] ?? '',
      profileImage: map['profileImage'] ?? '',
      coverPhoto: map['coverPhoto'],
      storeName: map['storeName'] ?? '',
      deliveryValue: map['deliveryValue'] ?? 0.0,
      rate: map['rate'] ?? 0.0,
      rateCount: map['rateCount'] ?? 0,


      address: addressJson != null && addressJson.isNotEmpty
          ? CreatorAddress.fromJson(jsonDecode(addressJson))
          : null,


      offers: offersJson != null && offersJson.isNotEmpty
          ? (jsonDecode(offersJson) as List)
          .map((e) => CreatorOffer.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],


      paymentMethods: paymentMethodsJson != null && paymentMethodsJson.isNotEmpty
          ? (jsonDecode(paymentMethodsJson) as List)
          .map((e) => CreatorPaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],


      availability: availabilityJson != null && availabilityJson.isNotEmpty
          ? (jsonDecode(availabilityJson) as List)
          .map((e) => CreatorAvailability.fromJson(e as Map<String, dynamic>))
          .toList()
          : [],
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}


// CreatorOffer
class CreatorOffer {
  final String type;
  final String value;
  final String start;
  final String end;

  CreatorOffer({
    required this.type,
    required this.value,
    required this.start,
    required this.end,
  });

  factory CreatorOffer.fromJson(Map<String, dynamic> json) {
    return CreatorOffer(
      type: json['type']?.toString() ?? '',
      value: json['value']?.toString() ?? '0.00',
      start: json['start']?.toString() ?? '',
      end: json['end']?.toString() ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'value': value,
      'start': start,
      'end': end,
    };
  }
}

// CreatorPaymentMethod
class CreatorPaymentMethod {
  final String method;
  final String? accountInfo;

  CreatorPaymentMethod({
    required this.method,
    this.accountInfo,
  });

  factory CreatorPaymentMethod.fromJson(Map<String, dynamic> json) {
    return CreatorPaymentMethod(
      method: json['method']?.toString() ?? '',
      accountInfo: json['account_info']?.toString(),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'account_info': accountInfo,
    };
  }
}

// CreatorAddress
class CreatorAddress {
  final String city;
  final String street;
  final String country;

  CreatorAddress({
    required this.city,
    required this.street,
    required this.country,
  });

  factory CreatorAddress.fromJson(Map<String, dynamic> json) {
    return CreatorAddress(
      city: json['city']?.toString() ?? '',
      street: json['street']?.toString() ?? '',
      country: json['country']?.toString() ?? '',
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'street': street,
      'country': country,
    };
  }
}

