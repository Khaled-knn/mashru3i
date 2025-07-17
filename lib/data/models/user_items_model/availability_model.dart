class Availability {
  final String type;
  final String openAt;
  final String closeAt;

  Availability({
    required this.type,
    required this.openAt,
    required this.closeAt,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      type: json['type']?.toString() ?? '',
      openAt: json['open_at']?.toString() ?? '',
      closeAt: json['close_at']?.toString() ?? '',
    );
  }
}
