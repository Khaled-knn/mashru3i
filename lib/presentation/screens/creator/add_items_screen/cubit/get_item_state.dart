import '../../../../../data/models/items_model/creator_item_model.dart';

abstract class GetItemsState {}

class GetItemsInitial extends GetItemsState {}

class GetItemsLoading extends GetItemsState {}

class GetItemsSuccess extends GetItemsState {
  final List<CreatorItemModel> items;

  GetItemsSuccess(this.items);
}

class GetItemsFailure extends GetItemsState {
  final String error;

  GetItemsFailure(this.error);



}
class DeleteItemSuccess extends GetItemsState {
  final String message;
  DeleteItemSuccess(this.message);
}
class GetItemsError extends GetItemsState {
  final String error;
  GetItemsError(this.error);
}

class UpdateItemLoading extends GetItemsState {

}

class UpdateItemSuccess extends GetItemsState {
  final String message;
  final int tokensDeducted;

  UpdateItemSuccess(this.message, this.tokensDeducted);

}