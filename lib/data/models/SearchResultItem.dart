import 'dart:convert';

class SearchResultItem {
  final String id;
  final String name;
  final double price;
  final String? description;
  final List<String>? pictures;
  final int professionId;
  final String itemType;

  final String? creatorName;
  final double? creatorRating;
  final bool? hasFreeDelivery;
  final bool? hasOffer;
  final bool? isOpenNow;

  final String? time;
  final List<String>? ingredients;
  final String? additionalData;
  final String? workingTime;
  final String? behanceLink;
  final List<String>? portfolioLinks;
  final String? courseDuration;
  final String? syllabus;
  final String? googleDriveLink;

  SearchResultItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.pictures,
    required this.professionId,
    required this.itemType,
    this.creatorName,
    this.creatorRating,
    this.hasFreeDelivery,
    this.hasOffer,
    this.isOpenNow,
    this.time,
    this. ingredients,
    this.additionalData,
    this.workingTime,
    this.behanceLink,
    this.portfolioLinks,
    this.courseDuration,
    this.syllabus,
    this.googleDriveLink,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'No Name',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'],

      pictures: (json['pictures'] as List?)?.map((e) => e.toString()).toList(),
      professionId: json['profession_id'] as int? ?? 0,
      itemType: json['item_type'] ?? 'unknown',

      creatorName: json['creator_name'],
      creatorRating: (json['rating'] as num?)?.toDouble(),

      hasFreeDelivery: json['has_free_delivery'] == 1 || json['has_free_delivery'] == true,
      hasOffer: json['has_offer'] == 1 || json['has_offer'] == true,
      isOpenNow: json['is_open_now'] == 1 || json['is_open_now'] == true,

      time: json['time'],
      ingredients: (json['ingredients'] as List?)?.map((e) => e.toString()).toList(),
      additionalData: json['additional_data'],
      workingTime: json['working_time'],
      behanceLink: json['behance_link'],
      portfolioLinks: (json['portfolio_links'] as List?)?.map((e) => e.toString()).toList(),
      courseDuration: json['course_duration'],
      syllabus: json['syllabus'],
      googleDriveLink: json['google_drive_link'],
    );
  }
}