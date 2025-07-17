

abstract class ItemState  {
  @override
  List<Object?> get props => [];
}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemSuccess extends ItemState {
  final int itemId;
  final String message ;

  ItemSuccess(this.itemId , this.message);

  @override
  List<Object?> get props => [itemId];
}

class ItemFailure extends ItemState {
  final String error;

  ItemFailure(this.error);

  @override
  List<Object?> get props => [error];
}

