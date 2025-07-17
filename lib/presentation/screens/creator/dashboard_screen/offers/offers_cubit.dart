import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../data/models/offer_model.dart';
import 'offers_states.dart';

class OffersCubit extends Cubit<OffersState> {
  OffersCubit() : super(OffersInitial());

  Future<void> fetchOffers() async {
    emit(OffersLoading());
    try {
      final int creatorId = CacheHelper.getData(key: 'userId');
      final response = await DioHelper.getData(url: '/api/offers/$creatorId');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final offers = data.map((e) => PromotionOffer.fromJson(e)).toList();
        emit(OffersLoaded(offers));
      } else {
        emit(OffersLoaded([]));
      }
    } catch (e) {
      emit(OffersError('failed_to_fetch_offers: ${e.toString()}'));
    }
  }

  Future<void> saveOffers(List<PromotionOffer> offers) async {
    emit(OffersLoading());
    try {
      final int creatorId = CacheHelper.getData(key: 'userId');

      final formattedOffers = offers.map((offer) => {
        'offer_type': offer.offerType,
        'offer_value': offer.offerValue,
        'offer_start': offer.offerStart.toIso8601String(),
        'offer_end': offer.offerEnd.toIso8601String(),
      }).toList();

      final response = await DioHelper.postListData(
        url: '/api/offers/$creatorId',
        data: formattedOffers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(OffersSuccess());
        await fetchOffers();
      } else {
        emit(OffersError('Failed to save offers: ${response.statusCode}'));
      }
    } catch (e) {
      emit(OffersError('Save error: ${e.toString()}'));
    }
  }
}
