// lib/data/models/items_model/teaching_item_details.dart (أو tutoring_item_details.dart)
import 'item_details_model.dart';

class TeachingItemDetails extends ItemDetailsModel { // أو TutoringItemDetails
  final String? courseDuration;
  final String? syllabus;
  final String? googleDriveLink;

  TeachingItemDetails({
    this.courseDuration,
    this.syllabus,
    this.googleDriveLink,
  });

  factory TeachingItemDetails.fromJson(Map<String, dynamic> json) {
    return TeachingItemDetails(
      courseDuration: json['course_duration'],
      syllabus: json['syllabus'],
      googleDriveLink: json['google_drive_link'],
    );
  }
}