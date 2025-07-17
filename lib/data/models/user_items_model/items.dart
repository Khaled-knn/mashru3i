import 'dart:convert';
import 'package:flutter/material.dart'; // استخدم Material.dart لأجل debugPrint

// تأكد من وجود هذا الملف
// lib/data/models/items_model/restaurant_item_details.dart
// (إذا كانت Ingredient موجودة هناك)
import '../items_model/restaurant_item_details.dart'; // لتضمين Ingredient Class
import 'availability_model.dart';


class Item {
  final int id;
  final int creatorId;
  final int categoryId;
  final String name;
  final double price; // ممكن يكون String بالـ API
  final List<String> pictures; // List من الـ URLs
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int professionId;
  final double? discount; // ممكن يكون null
  final String creatorName;
  final String? creatorPhone;
  final String creatorImage;
  final String storeName;
  final double deliveryValue; // ممكن يكون String بالـ API
  final String? coverPhoto;

  // حقول الـ details اللي بتجي مباشرة من الـ API
  final String? restaurantTime;
  final List<Ingredient>? restaurantIngredients; // List من الـ Ingredient objects

  final String? hsWorkingTime;
  final String? hsBehanceLink;
  final String? hsPortfolioLinks;

  final String? tutoringCourseDuration;
  final String? tutoringSyllabus;

  final String? hcTime;
  final List<Ingredient>? hcIngredients; // List من الـ Ingredient objects
  final String? hcAdditionalData;

  final String? freelancerWorkingTime;
  final String? freelancerPortfolioLinks;

  // الحقول الأخرى
  final Availability? availability;
  final List<String> paymentMethod;
  final String? creatorCity;
  final String? creatorCountry;
  final String? creatorStreet;

  Item({
    required this.id,
    required this.creatorId,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.pictures,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.professionId,
    this.discount,
    required this.creatorName,
    this.creatorPhone,
    required this.creatorImage,
    required this.storeName,
    required this.deliveryValue,
    this.coverPhoto,
    this.restaurantTime,
    this.restaurantIngredients,
    this.hsWorkingTime,
    this.hsBehanceLink,
    this.hsPortfolioLinks,
    this.tutoringCourseDuration,
    this.tutoringSyllabus,
    this.hcTime,
    this.hcIngredients,
    this.hcAdditionalData,
    this.freelancerWorkingTime,
    this.freelancerPortfolioLinks,
    // باقي الحقول
    this.availability,
    required this.paymentMethod,
    this.creatorCity,
    this.creatorCountry,
    this.creatorStreet,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: _parseInt(json['id']),
      creatorId: _parseInt(json['creator_id']),
      categoryId: _parseInt(json['category_id']),
      name: json['name']?.toString() ?? '',
      price: _parseDouble(json['price']), // ممكن يكون String
      pictures: _parsePictures(json['pictures']), // تحتاج لفك تشفير JSON
      description: json['description']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
      professionId: _parseInt(json['profession_id']),
      discount: json['discount'] != null ? _parseDouble(json['discount']) : null,
      creatorName: json['creator_name']?.toString() ?? '',
      creatorPhone: json['creator_phone']?.toString(),
      creatorImage: json['creator_image']?.toString() ?? '',
      storeName: json['store_name']?.toString() ?? '',
      deliveryValue: _parseDouble(json['deliveryValue']), // ممكن يكون String
      coverPhoto: json['cover_photo']?.toString(),

      // قراءة حقول تفاصيل المهن مباشرة من الـ JSON
      restaurantTime: json['restaurant_time']?.toString(),
      restaurantIngredients: _parseIngredients(json['restaurant_ingredients']), // تحتاج لفك تشفير JSON

      hsWorkingTime: json['hs_working_time']?.toString(),
      hsBehanceLink: json['hs_behance_link']?.toString(),
      hsPortfolioLinks: json['hs_portfolio_links']?.toString(),

      tutoringCourseDuration: json['tutoring_course_duration']?.toString(),
      tutoringSyllabus: json['tutoring_syllabus']?.toString(),

      hcTime: json['hc_time']?.toString(),
      hcIngredients: _parseIngredients(json['hc_ingredients']), // تحتاج لفك تشفير JSON
      hcAdditionalData: json['hc_additional_data']?.toString(), // هذا غالباً String أو null

      freelancerWorkingTime: json['freelancer_working_time']?.toString(),
      freelancerPortfolioLinks: json['freelancer_portfolio_links']?.toString(),

      // الحقول الأخرى
      availability: _parseAvailability(json['availability']),
      paymentMethod: _parseStringList(json['payment_method']), // إذا كانت ترجع كـ String JSONified
      creatorCity: json['creator_city']?.toString(),
      creatorCountry: json['creator_country']?.toString(),
      creatorStreet: json['creator_street']?.toString(),
    );
  }

  // دوال التحويل المساعدة (مُحسّنة)
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

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static List<String> _parsePictures(dynamic pictures) {
    if (pictures == null) return [];
    try {
      // الـ Backend عم يبعتها String مشفرة بـ JSON
      if (pictures is String) {
        final decodedList = jsonDecode(pictures);
        if (decodedList is List) {
          return decodedList.map((e) => e.toString()).toList();
        }
      } else if (pictures is List) { // في حال Backend غير السلوك مستقبلاً
        return pictures.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error parsing pictures: $e');
    }
    return [];
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    try {
      if (value is String) {
        final decoded = jsonDecode(value);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      } else if (value is List) {
        return value.map((e) => e.toString()).toList();
      }
    } catch (e) {
      debugPrint('Error parsing StringList: $e');
    }
    return [];
  }

  static List<Ingredient>? _parseIngredients(dynamic ingredients) {
    if (ingredients == null) return null;
    try {
      dynamic decodedIngredients = ingredients;
      // إذا كانت Ingredients بتجي String JSONified (مثل "[]")
      if (ingredients is String) {
        decodedIngredients = jsonDecode(ingredients);
      }

      if (decodedIngredients is List) {
        // تأكد إن Ingredient model موجود ومناسب لتركيبة العناصر داخل الـ ingredients
        return decodedIngredients.map<Ingredient>((e) {
          if (e is Map<String, dynamic>) {
            return Ingredient.fromJson(e);
          }
          // fallback أو رمي خطأ إذا العنصر ليس Map
          return Ingredient(name: '', price: 0.0); // قم بتعديل هذا ليتناسب مع constructor الـ Ingredient الخاص بك
        }).toList();
      }
    } catch (e) {
      debugPrint('Error parsing ingredients: $e');
    }
    return null;
  }

  static Availability? _parseAvailability(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;

    try {
      dynamic decodedValue = value;
      // إذا كان String داخل String (double encoded)
      if (value is String) {
        try {
          decodedValue = jsonDecode(value); // أول decode
        } catch (_) {
          // إذا كان JSON غير صالح كـ String عادي، فليكون هو القيمة الأصلية
          decodedValue = value;
        }
      }

      // إذا كان بعد فك التشفير مازال String (يعني كان double encoded)
      if (decodedValue is String) {
        try {
          decodedValue = jsonDecode(decodedValue); // تاني decode
        } catch (_) {
          // إذا كان JSON غير صالح مرة أخرى
          return null;
        }
      }

      if (decodedValue is Map<String, dynamic>) {
        return Availability.fromJson(decodedValue);
      }
    } catch (e) {
      debugPrint('Error parsing availability: $e');
    }
    return null;
  }

}