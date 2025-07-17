import 'dart:convert';
import 'item_details_model.dart';

class FreelancerItemDetails extends ItemDetailsModel {
  final String? workingTime;
  final List<String>? portfolioLinks;

  FreelancerItemDetails({this.workingTime, this.portfolioLinks});

  factory FreelancerItemDetails.fromJson(Map<String, dynamic> json) {
    List<String>? parsedLinks;
    final dynamic rawLinks = json['portfolio_links'];

    if (rawLinks != null) {
      if (rawLinks is String) {
        try {
          final List<dynamic> decodedList = jsonDecode(rawLinks);
          parsedLinks = decodedList.map((e) => e.toString()).toList();
        } catch (e) {
          print('Error parsing portfolio_links string: $e');
          parsedLinks = null;
        }
      } else if (rawLinks is List) {
        parsedLinks = rawLinks.map((e) => e.toString()).toList();
      }
    }

    return FreelancerItemDetails(
      workingTime: json['working_time'],
      portfolioLinks: parsedLinks,
    );
  }
}