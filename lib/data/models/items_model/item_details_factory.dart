import 'item_details_model.dart';
import 'restaurant_item_details.dart';
import 'hs_item_details.dart';
import 'hc_item_details.dart';
import 'freelancer_item_details.dart';
import 'teaching_item_details.dart';

class ItemDetailsFactory {
  static ItemDetailsModel? fromJson(int professionId, Map<String, dynamic> json) {
    if (json.isEmpty) {
      return null;
    }

    switch (professionId) {
      case 1: // Food Chef
      case 2: // Sweet Chef
        return RestaurantItemDetails.fromJson(json);
      case 3: // Home Services
        return HsItemDetails.fromJson(json);
      case 4: // Hand Crafter
        return HcItemDetails.fromJson(json);
      case 5: // Freelancer's
        return FreelancerItemDetails.fromJson(json);
      case 6: // Tutoring
        return TeachingItemDetails.fromJson(json);
      default:
        print('Unknown profession ID: $professionId. Details cannot be parsed.');
        return null;
    }
  }
}