// lib/data/models/items_model/hs_item_details.dart
import 'item_details_model.dart';

class HsItemDetails extends ItemDetailsModel {
  final String? workingTime;
  final String? behanceLink;
  final List<String>? portfolioLinks;

  HsItemDetails({this.workingTime, this.behanceLink, this.portfolioLinks});

  factory HsItemDetails.fromJson(Map<String, dynamic> json) {
    return HsItemDetails(
      workingTime: json['working_time'],
      behanceLink: json['behance_link'],
      portfolioLinks: (json['portfolio_links'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}