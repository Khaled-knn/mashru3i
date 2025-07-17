class CreatorAvailability {
  final String type;
  final String openAt;
  final String closeAt;
  final List<String>? days; // بما أنها List<String>?، ممكن تكون null

  CreatorAvailability({
    required this.type,
    required this.openAt,
    required this.closeAt,
    this.days,
  });

  factory CreatorAvailability.fromJson(Map<String, dynamic> json) {
    return CreatorAvailability(
      type: json['type']?.toString() ?? '',
      openAt: json['open_at']?.toString() ?? '',
      closeAt: json['close_at']?.toString() ?? '',
      days: (json['days'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  // دالة toJson() لتحويل الكائن إلى Map<String, dynamic>
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'open_at': openAt,
      'close_at': closeAt,
      'days': days, // بما أنها List<String>، تُحفظ مباشرةً
    };
  }
}