import 'dart:convert';

import 'package:mashrou3i/data/models/user_items_model/CreatorAvailability.dart';

class Availability {
  final String type; // daily or specific
  final String openAt; // "09:00"
  final String closeAt; // "17:00"
  final List<String> days; // Changed from List<int> to List<String>

  Availability({
    required this.type,
    required this.openAt,
    required this.closeAt,
    required this.days,
  });

  CreatorAvailability toCreatorAvailability() {
    return CreatorAvailability(
      type: type,
      openAt: openAt,
      closeAt: closeAt,
      days: days ?? [],
    );
  }

  factory Availability.fromJson(Map<String, dynamic> json) {
    List<String> parsedDays = [];

    if (json['days'] is String) {
      try {
        final rawList = jsonDecode(json['days']) as List<dynamic>;
        parsedDays = rawList.map((e) => e.toString()).toList();
        print('Availability.fromJson: Parsed days from JSON string: $parsedDays');
      } catch (e) {
        print('Availability.fromJson: Error parsing days string as JSON: $e');
        parsedDays = [];
      }
    }
    else if (json['days'] is List) {
      parsedDays = (json['days'] as List<dynamic>).map((e) => e.toString()).toList();
      print('Availability.fromJson: Days is already a List: $parsedDays');
    } else {
      print('Availability.fromJson: "days" field is null or unexpected type: ${json['days']}');
      parsedDays = [];
    }

    String typeValue = json['type']?.isNotEmpty == true ? json['type'] : 'daily';

    return Availability(
      type: typeValue,
      openAt: _formatTime(json['open_at'] ?? '09:00'),
      closeAt: _formatTime(json['close_at'] ?? '17:00'),
      days: parsedDays,
    );
  }

  static String _formatTime(String time) {
    // Convert "02:00:00" to "02:00"
    return time.split(':').take(2).join(':');
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'open_at': openAt,
      'close_at': closeAt,
      'days': type == 'daily' ? [] : days,
    };
  }

}