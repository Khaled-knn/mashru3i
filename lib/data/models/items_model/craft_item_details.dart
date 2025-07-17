import 'item_details_model.dart';

class CraftItemDetails extends ItemDetailsModel {
  final String? workingTime;
  final String? behanceLink;
  final List<String>? portfolioLinks;

  CraftItemDetails({this.workingTime, this.behanceLink, this.portfolioLinks});

  factory CraftItemDetails.fromJson(Map<String, dynamic> json) {
    return CraftItemDetails(
      workingTime: json['working_time'],
      behanceLink: json['behance_link'],
      portfolioLinks: (json['portfolio_links'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}
