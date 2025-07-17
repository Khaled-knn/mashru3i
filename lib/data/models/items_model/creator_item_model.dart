import 'dart:convert';
import 'package:mashrou3i/data/models/items_model/freelancer_item_details.dart';
import 'package:mashrou3i/data/models/items_model/hs_item_details.dart';
import 'package:mashrou3i/data/models/items_model/hc_item_details.dart';
import 'package:mashrou3i/data/models/items_model/restaurant_item_details.dart';
import 'package:mashrou3i/data/models/items_model/teaching_item_details.dart';
import 'package:mashrou3i/data/models/items_model/item_details_model.dart';
import 'package:mashrou3i/data/models/items_model/item_details_factory.dart';

class CreatorItemModel {
  final int id;
  final int creatorId;
  final int categoryId;
  final String name;
  final double price;
  final List<String>? pictures;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int professionId;
  final ItemDetailsModel? details;

  CreatorItemModel({
    required this.id,
    required this.creatorId,
    required this.categoryId,
    required this.name,
    required this.price,
    this.pictures,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.professionId,
    this.details,
  });

  factory CreatorItemModel.fromJson(Map<String, dynamic> json) {
    final int itemProfessionId = json['category_id'];
    final detailsJson = json['details'];

    List<String>? parsedPictures;
    if (json['pictures'] != null) {
      if (json['pictures'] is String) {
        try {
          final List<dynamic> decodedPictures = jsonDecode(json['pictures']);
          parsedPictures = decodedPictures.map((e) => e.toString()).toList();
        } catch (e) {
          print('Error parsing pictures string for item ${json['id']}: $e');
          parsedPictures = null;
        }
      } else if (json['pictures'] is List) {
        parsedPictures = (json['pictures'] as List<dynamic>).map((e) => e.toString()).toList();
      }
    }

    ItemDetailsModel? itemDetails;
    if (detailsJson != null && detailsJson is Map<String, dynamic>) {
      itemDetails = ItemDetailsFactory.fromJson(itemProfessionId, detailsJson);
    }


    double parsedPrice;
    final priceValue = json['price'];

    if (priceValue is String) {
      parsedPrice = double.tryParse(priceValue) ?? 0.0;
    } else if (priceValue is num) {

      parsedPrice = priceValue.toDouble();
    } else {

      parsedPrice = 0.0;
    }


    return CreatorItemModel(
      id: json['id'],
      creatorId: json['creator_id'],
      categoryId: json['category_id'],
      name: json['name'],
      price: parsedPrice,
      pictures: parsedPictures,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      professionId: itemProfessionId,
      details: itemDetails,
    );
  }
}