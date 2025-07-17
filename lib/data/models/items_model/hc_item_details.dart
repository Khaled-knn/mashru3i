// lib/data/models/items_model/hc_item_details.dart
import 'item_details_model.dart';

class HcItemDetails extends ItemDetailsModel {
  final String? time;

  HcItemDetails({this.time});

  factory HcItemDetails.fromJson(Map<String, dynamic> json) {
    return HcItemDetails(
      time: json['time'] as String?,
    );
  }

}