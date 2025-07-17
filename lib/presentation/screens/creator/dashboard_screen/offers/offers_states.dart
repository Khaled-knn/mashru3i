import '../../../../../data/models/offer_model.dart';

abstract class OffersState {}

class OffersInitial extends OffersState {}

class OffersLoading extends OffersState {}

class OffersLoaded extends OffersState {
  final List<PromotionOffer> offers;
  OffersLoaded(this.offers);
}

class OffersSuccess extends OffersState {}

class OffersError extends OffersState {
  final String message;
  OffersError(this.message);
}
