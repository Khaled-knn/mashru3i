import 'package:flutter/cupertino.dart';
import '../../../../../../data/creatorsItems.dart';
import '../../../../../../data/models/advertisement_model.dart';
import '../../../../../../data/models/user_items_model/ItemSearch.dart';
import '../../../../../../data/models/user_items_model/items.dart';

@immutable
abstract class UserItemsState {
  const UserItemsState();
}

// ---------- ITEMS STATES ----------

class UserItemsInitial extends UserItemsState {
  const UserItemsInitial();
}

class UserItemsLoading extends UserItemsState {
  const UserItemsLoading();
}

class UserItemsLoaded extends UserItemsState {
  final List<Item> items;
  final bool showCreatorDetails;

  const UserItemsLoaded({
    required this.items,
    this.showCreatorDetails = true,
  });

  @override
  String toString() => 'UserItemsLoaded(items: ${items.length} items)';
}

class UserItemsError extends UserItemsState {
  final String message;
  const UserItemsError({required this.message});

  @override
  String toString() => 'UserItemsError(message: $message)';
}

// ---------- CREATORS STATES ----------

class UserCreatorsLoading extends UserItemsState {
  const UserCreatorsLoading();
}

class UserCreatorsLoaded extends UserItemsState {
  final List<CreatorItem> items;
  final bool showCreatorDetails;

  const UserCreatorsLoaded({
    required this.items,
    this.showCreatorDetails = true,
  });

  @override
  String toString() => 'UserCreatorsLoaded(items: ${items.length} items)';
}

class UserCreatorsError extends UserItemsState {
  final String message;
  const UserCreatorsError({required this.message});

  @override
  String toString() => 'UserCreatorsError(message: $message)';
}
class UserItemsRatingSuccess extends UserItemsState {}
class UserItemsRatingLoading extends UserItemsState {}

class UserItemsRatingError extends UserItemsState {
  final String message;
  const UserItemsRatingError({required this.message});

  @override
  String toString() => 'UserItemsError(message: $message)';

}


class UserSearchItemsLoaded extends UserItemsState {

  final List<ItemFull> searchResults;
  UserSearchItemsLoaded({required this.searchResults});
}

class ActiveAdvertisementsLoadingState extends UserItemsState {}
class ActiveAdvertisementsSuccessState extends UserItemsState {
  final List<Advertisement> advertisements;
  ActiveAdvertisementsSuccessState(this.advertisements);
}
class ActiveAdvertisementsErrorState extends UserItemsState {
  final String error;
  ActiveAdvertisementsErrorState(this.error);
}