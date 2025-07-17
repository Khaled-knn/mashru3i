class Advertisement {
  final String imageUrl;
  final String? redirectUrl;

  Advertisement({
    required this.imageUrl,
    this.redirectUrl,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      imageUrl: json['image_url'],
      redirectUrl: json['redirect_url'],
    );
  }
}