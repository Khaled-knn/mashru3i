import 'package:easy_localization/easy_localization.dart';

class PromotionOffer {
  final String offerType;
  final double offerValue;
  final DateTime offerStart;
  final DateTime offerEnd;


  PromotionOffer({
    required this.offerType,
    required this.offerValue,
    required this.offerStart,
    required this.offerEnd,
  });


  bool get isActive {
    final now = DateTime.now();

    return now.isAfter(offerStart) && now.isBefore(offerEnd);
  }

  factory PromotionOffer.fromJson(Map<String, dynamic> json) {
    return PromotionOffer(
      offerType: json['offer_type'],
      offerValue: double.parse(json['offer_value'].toString()),
      offerStart: DateTime.parse(json['offer_start']),
      offerEnd: DateTime.parse(json['offer_end']),
    );
  }

  Map<String, dynamic> toJson() => {
    'offer_type': offerType,
    'offer_value': offerValue.toStringAsFixed(2),
    'offer_start': offerStart.toIso8601String(),
    'offer_end': offerEnd.toIso8601String(),

  };

  String get formattedDiscount => '${offerValue.toStringAsFixed(0)}%';

  String get dateRange {
    final start = DateFormat('dd MMM').format(offerStart);
    final end = DateFormat('dd MMM').format(offerEnd);
    return '$start - $end';
  }


  PromotionOffer copyWith({
    String? offerType,
    double? offerValue,
    DateTime? offerStart,
    DateTime? offerEnd,

  }) {
    return PromotionOffer(
      offerType: offerType ?? this.offerType,
      offerValue: offerValue ?? this.offerValue,
      offerStart: offerStart ?? this.offerStart,
      offerEnd: offerEnd ?? this.offerEnd,
    );
  }
}