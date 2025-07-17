import 'package:equatable/equatable.dart';

class CreatorPaymentMethodModel extends Equatable {
  final String method;
  final String? accountInfo;

  const CreatorPaymentMethodModel({
    required this.method,
    this.accountInfo,
  });

  factory CreatorPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return CreatorPaymentMethodModel(
      method: json['method'] as String,
      accountInfo: json['account_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'account_info': accountInfo,
    };
  }

  @override
  List<Object?> get props => [method, accountInfo];
}