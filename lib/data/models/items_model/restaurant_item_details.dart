
import 'dart:convert';

import 'item_details_model.dart';


class RestaurantItemDetails extends ItemDetailsModel {
  final String? time;
  final List<Ingredient>? ingredients;

  RestaurantItemDetails({this.time, this.ingredients});

  factory RestaurantItemDetails.fromJson(Map<String, dynamic> json) {
    List<Ingredient>? parsedIngredients;
    final dynamic rawIngredients = json['ingredients'];

    if (rawIngredients is String && rawIngredients.isNotEmpty) {

      try {
        final decoded = jsonDecode(rawIngredients);
        if (decoded is List) {
          parsedIngredients = decoded.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
        }
      } catch (e) {
        print('Error decoding ingredients string in RestaurantItemDetails: $e');
        parsedIngredients = [];
      }
    } else if (rawIngredients is List) {
      parsedIngredients = rawIngredients.map((e) => Ingredient.fromJson(e as Map<String, dynamic>)).toList();
    }

    return RestaurantItemDetails(
      time: json['time'],
      ingredients: parsedIngredients,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'ingredients': ingredients?.map((e) => e.toJson()).toList(),
    };
  }
}

class Ingredient {
  final String name;
  final num price;

  Ingredient({required this.name, required this.price});

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'],
      price: json['price'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
    };
  }
}