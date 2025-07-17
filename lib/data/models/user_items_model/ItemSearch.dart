import 'dart:convert';
import 'package:intl/intl.dart';

import '../../creatorsItems.dart';
import '../availability_model.dart';

class ItemFull {
  final int id;
  final String name;
  final double price;
  final String description;
  final List<String> pictures;
  final int professionId;
  final int creatorId;
  final String creatorName;
  final String creatorImage;
  final String creatorPhone;
  final String storeName;
  final double deliveryValue;
  final String coverPhoto;
  final String? time;
  final List<Ingredient>? ingredients;
  final List<String>? portfolioLinks;
  final String? syllabus;
  final List<Availability> availability;
  final List<CreatorOffer> offers;
  final List<CreatorPaymentMethod> paymentMethods;
  final Map<String, dynamic> address;
  final double rating;
  final int rateCount;

  ItemFull({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.pictures,
    required this.professionId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorImage,
    required this.creatorPhone,
    required this.storeName,
    required this.deliveryValue,
    required this.coverPhoto,
    this.time,
    this.ingredients,
    this.portfolioLinks,
    this.syllabus,
    required this.availability,
    required this.offers,
    required this.paymentMethods,
    required this.address,
    required this.rating,
    required this.rateCount,
  });

  factory ItemFull.fromJson(Map<String, dynamic> json) {
    return ItemFull(
      id: json['id'] as int,
      name: json['name'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
      description: json['description'] as String,
      pictures: _parsePictures(json['pictures']),
      professionId: json['profession_id'] as int,
      creatorId: json['creator_id'] as int,
      creatorName: json['creator_name'] as String,
      creatorImage: json['creator_image'] as String,
      creatorPhone: json['creator_phone'] as String,
      storeName: json['store_name'] as String,
      deliveryValue: double.tryParse(json['delivery_value']?.toString() ?? '0') ?? 0,
      coverPhoto: json['cover_photo'] as String,
      time: json['time']?.toString(),
      ingredients: _parseIngredients(json['ingredients']),
      portfolioLinks: _parsePortfolioLinks(json['portfolio_links']),
      syllabus: json['syllabus']?.toString(),
      availability: (json['availability'] as List)
          .map((e) => Availability.fromJson(e))
          .toList(),
      offers: (json['offers'] as List)
          .map((e) => CreatorOffer.fromJson(e))
          .toList(),
      paymentMethods: (json['payment_methods'] as List)
          .map((e) => CreatorPaymentMethod.fromJson(e))
          .toList(),
      address: json['address'] as Map<String, dynamic>,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      rateCount: json['rate_count'] as int,
    );



  }


  static List<String> _parsePictures(dynamic pictures) {
    if (pictures is List) return pictures.cast<String>();
    if (pictures is String) {
      try {
        return (jsonDecode(pictures) as List).cast<String>();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  static List<Ingredient>? _parseIngredients(dynamic ingredients) {
    if (ingredients == null) return null;
    if (ingredients is String) {
      try {
        final parsed = jsonDecode(ingredients) as List;
        return parsed.map((e) => Ingredient.fromJson(e)).toList();
      } catch (e) {
        return null;
      }
    }
    if (ingredients is List) {
      return ingredients.map((e) => Ingredient.fromJson(e)).toList();
    }
    return null;
  }

  static List<String>? _parsePortfolioLinks(dynamic links) {
    if (links == null) return null;
    if (links is List) return links.cast<String>();
    if (links is String) {
      try {
        return (jsonDecode(links) as List).cast<String>();
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  CreatorItem toCreatorItem() {
    return CreatorItem(
      id: creatorId,
      fullName: creatorName,
      profileImage: creatorImage,
      coverPhoto: coverPhoto,
      storeName: storeName,
      deliveryValue: deliveryValue,
      offers: offers,
      paymentMethods: paymentMethods,
      availability: availability.map((a) => a.toCreatorAvailability()).toList(),
      rate: rating,
      rateCount: rateCount,
      address: CreatorAddress(
        city: address['city'] as String? ?? '',
        street: address['street'] as String? ?? '',
        country: address['country'] as String? ?? '',
      ),
    );
  }

  bool get isAvailable {
    if (availability.isEmpty) return false;

    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now);

    for (final slot in availability) {
      try {
        // لو محدد أيام وكان اليوم مو ضمنها، تخطي
        if (slot.days != null && slot.days!.isNotEmpty && !slot.days!.contains(today)) continue;

        final openTime = _parseTime(slot.openAt, now);
        var closeTime = _parseTime(slot.closeAt, now);

        if (closeTime.isBefore(openTime)) {
          closeTime = closeTime.add(const Duration(days: 1));
        }

        if (now.isAfter(openTime) && now.isBefore(closeTime)) {
          return true;
        }
      } catch (e) {
        print('Error processing availability slot: $slot, error: $e');
        continue;
      }
    }
    return false;
  }


  DateTime _parseTime(String time, DateTime date) {
    try {
      final parts = time.split(':');

      // توقع كلا التنسيقين: HH:mm و HH:mm:ss
      final hour = int.parse(parts[0]);
      final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
      final second = parts.length > 2 ? int.parse(parts[2]) : 0;

      return DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
        second,
      );
    } catch (e) {
      print('Error parsing time: $time, error: $e');
      // وقت افتراضي عند الخطأ (9 صباحًا)
      return DateTime(
        date.year,
        date.month,
        date.day,
        9,
        0,
        0,
      );
    }
  }
}

class Ingredient {
  final String name;
  final double price;

  Ingredient({required this.name, required this.price});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0,
    );
  }
}