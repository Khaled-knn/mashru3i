class PaymentMethod {
  final String method;
  final String? accountInfo;

  PaymentMethod({
    required this.method,
    this.accountInfo,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      method: json['method'],
      accountInfo: json['account_info'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'account_info': accountInfo,
    };
  }
}
