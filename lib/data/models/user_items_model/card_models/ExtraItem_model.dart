import 'package:equatable/equatable.dart';

class ExtraItem extends Equatable {
  final String name;
  final double price;

  const ExtraItem({required this.name, required this.price});

  factory ExtraItem.fromJson(Map<String, dynamic> json) {
    return ExtraItem(
      name: json['name'] as String, // الآن دائماً String
      price: double.parse(json['price'].toString()), // بيظل Parse لأنه ممكن يجي int أو string
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }

  @override
  List<Object?> get props => [name, price];
}