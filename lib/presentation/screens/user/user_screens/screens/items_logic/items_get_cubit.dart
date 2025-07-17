import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:mashrou3i/core/network/local/cach_helper.dart';

import '../../../../../../core/helper/user_data_manager.dart';
import '../../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../../core/network/remote/dio.dart';
import '../../../../../../data/creatorsItems.dart';
import '../../../../../../data/models/advertisement_model.dart';
import '../../../../../../data/models/user_items_model/ItemSearch.dart';
import '../../../../../../data/models/user_items_model/items.dart';
import 'items_git_states.dart';

class UserItemsCubit extends Cubit<UserItemsState> {

  UserItemsCubit() : super(UserItemsInitial());
  List<CreatorItem> _creatorsCache = [];
  final Map<int, List<Item>> _cachedItems = {};




  Future<void> fetchItemsByProfessionId(int creatorId) async {
    emit(UserItemsLoading());
    try {
      print('Calling: $GET_ITEMS_BY_CREATOR/$creatorId');
      final response = await DioHelper.getData(
        url: '$GET_ITEMS_BY_CREATOR/$creatorId',
      );
      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final responseData = response.data;
      if (responseData['data'] == null || responseData['data'] is! List) {
        throw Exception('Invalid data format');
      }

      final itemsData = responseData['data'] as List;
      final items = <Item>[];
      for (var item in itemsData) {
        if (item is Map<String, dynamic>) {
          try {
            items.add(Item.fromJson(item));
          } catch (e) {
            debugPrint('Failed to parse item: $e');
            continue;
          }
        }
      }
      emit(UserItemsLoaded(items: items));
    } on DioException catch (e) {
      emit(UserItemsError(
        message: 'NO ITEM HERE',
      ));
    } catch (e) {
      emit(UserItemsError(
        message: 'Failed to load items: ${e.toString()}',
      ));
    }
  }



  Future<void> fetchCreatorByProfessionId(
      int professionId, {
        String? search,
        double? minRate,
        bool freeDelivery = false,
        bool hasOffer = false,
        bool isOpenNow = false,
      }) async {
    emit(UserCreatorsLoading());
    try {
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (minRate != null) {
        queryParams['minRate'] = minRate.toString();
      }
      if (freeDelivery) {
        queryParams['freeDelivery'] = 'true';
      }
      if (hasOffer) {
        queryParams['hasOffer'] = 'true';
      }
      if (isOpenNow) {
        queryParams['isOpenNow'] = 'true';
      }

      print('Calling: $USERGETCREATOR/$professionId with params: $queryParams');

      final response = await DioHelper.getData(
        url: '$USERGETCREATOR/$professionId',
        query: queryParams,
      );

      final responseData = response.data;
      if (responseData == null || responseData['data'] == null) {
        emit(UserCreatorsError(message: 'No data found'));
        return;
      }

      final creatorsData = responseData['data'] as List;
      final creators = <CreatorItem>[];

      for (var item in creatorsData) {
        try {
          final map = Map<String, dynamic>.from(item);
          creators.add(CreatorItem.fromJson(map));
        } catch (e) {
          debugPrint('Failed to parse creator: $e\nItem: $item');
          continue;
        }
      }
      _creatorsCache = creators;
      emit(UserCreatorsLoaded(items: creators));
    } on DioException {
      emit(UserCreatorsError(message: 'NO CREATORS FOUND'));
    } catch (e) {
      emit(UserCreatorsError(message: 'Failed to load creators: $e'));
    }
  }

  CreatorItem? getCreatorById(int? id) {
    if (id == null) return null;
    try {
      return _creatorsCache.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }


  Future<void> submitItemRating({
    required int userId,
    required int creatorId,
    required double rating,
    String? comment,
  }) async {
    emit(UserItemsRatingLoading());
    try {

      print(userId);
      print(creatorId);
    print(rating is double);
    print(rating);
      final user = UserDataManager.getUserModel();
      final response = await DioHelper.postData(
        url: ITEM_RATING_ENDPOINT,
        data: {
          'creator_id': creatorId,
          'user_id': user!.id,
          'rating': rating,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },

      );
      if (response.statusCode == 200) {
        final success = response.data['success'];
        if (success == true || success.toString().toLowerCase() == 'true') {

          emit(UserItemsRatingSuccess());
          fetchItemsByProfessionId(creatorId);
        } else {
          emit(UserItemsRatingError(message:response.data is Map
          ? response.data['message']
              : 'Failed to submit rating',));
        }
      } else {
        emit(UserItemsRatingError(message: 'Failed to submit rating'));
      }
    } on DioException catch (e) {
      emit(UserItemsRatingError(
        message: e.response?.data is Map
            ? e.response?.data['message']
            : 'Failed to submit rating',
      ));
    } catch (e) {
      emit(UserItemsRatingError(message: 'Unexpected error occurred'));
    }
  }


  Future<void> fetchSearchItems({
    String? query,
    int? professionId,
    double? minRate,
    bool freeDelivery = false,
    bool hasOffer = false,
    bool isOpenNow = false,
    String? time,
    String? workingTime,
    String? courseDuration,
    int limit = 20,
    int offset = 0,
  }) async {
    emit(UserItemsLoading());
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit.toString(),
        'offset': offset.toString(),
      };

      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }
      if (professionId != null) {
        queryParams['professionId'] = professionId.toString();
      }
      if (minRate != null) {
        queryParams['minRate'] = minRate.toString();
      }
      if (freeDelivery) {
        queryParams['freeDelivery'] = 'true';
      }
      if (hasOffer) {
        queryParams['hasOffer'] = 'true';
      }
      if (isOpenNow) {
        queryParams['isOpenNow'] = 'true';
      }
      if (time != null && time.isNotEmpty) {
        queryParams['time'] = time;
      }
      if (workingTime != null && workingTime.isNotEmpty) {
        queryParams['working_time'] = workingTime;
      }
      if (courseDuration != null && courseDuration.isNotEmpty) {
        queryParams['course_duration'] = courseDuration;
      }

      print('Calling Search Items API: ${'/api/search'} with params: $queryParams');

      final response = await DioHelper.getData(
        url:'/api/search',
        query: queryParams,
      );

      final responseData = response.data;
      if (responseData == null || responseData['results'] == null || responseData['results'] is! List) {
        emit(UserItemsError(message: 'Invalid search data format or no results found'));
        return;
      }

      final searchResultsData = responseData['results'] as List;
      final List<ItemFull> searchResults = [];

      for (var item in searchResultsData) {
        if (item is Map<String, dynamic>) {
          try {
            searchResults.add(ItemFull.fromJson(item));
          } catch (e) {
            debugPrint('Failed to parse search item: $e\nItem data: $item');
            continue;
          }
        }
      }

      emit(UserSearchItemsLoaded(searchResults: searchResults));
    } on DioException catch (e) {
      debugPrint('Dio error during search: ${e.response?.statusCode} - ${e.message}');
      emit(UserItemsError(message: 'Failed to search items: ${e.response?.data['error'] ?? e.message}'));
    } catch (e) {
      debugPrint('Unexpected error during search: $e');
      emit(UserItemsError(message: 'Unexpected error occurred during search: ${e.toString()}'));
    }
  }







  Future<void> fetchActiveAdvertisements() async {
    print('UserItemsCubit: fetchActiveAdvertisements called.');
    emit(ActiveAdvertisementsLoadingState());
    print('UserItemsCubit: Emitted ActiveAdvertisementsLoadingState.');

    try {
      final response = await DioHelper.getData(
        url: '/api/public/advertisements/active',
      );

      print('UserItemsCubit: API Response Status Code: ${response.statusCode}');
      print('UserItemsCubit: API Response Data: ${response.data}');
      print('UserItemsCubit: API Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final dynamic rawAdvertisements = response.data['advertisements'];

        if (rawAdvertisements is! List) {
          print("UserItemsCubit: ERROR - 'advertisements' is not a list. Type: ${rawAdvertisements.runtimeType}");
          emit(ActiveAdvertisementsErrorState('Invalid API response: Advertisements data is not a list.'));
          return;
        }

        List<Advertisement> activeAdvertisements = [];
        if (rawAdvertisements.isNotEmpty) {
          activeAdvertisements = (rawAdvertisements as List)
              .map((e) {
            print('UserItemsCubit: Processing element: $e, Type: ${e.runtimeType}');
            if (e is Map<String, dynamic>) {
              return Advertisement.fromJson(e);
            } else {
              print('UserItemsCubit: ERROR - List element is not a Map. Type: ${e.runtimeType}, Value: $e');
              throw FormatException('Invalid item in advertisements list: Expected Map, got ${e.runtimeType}');
            }
          })
              .toList();
        }

        print("UserItemsCubit: Fetched Advertisements count: ${activeAdvertisements.length}");
        if (activeAdvertisements.isEmpty) {
          print("UserItemsCubit: WARNING - No active advertisements found from API.");
        }
        emit(ActiveAdvertisementsSuccessState(activeAdvertisements));
        print('UserItemsCubit: Emitted ActiveAdvertisementsSuccessState.');

      } else {
        String errorMessage = response.data?['message'] ?? 'Failed to fetch active advertisements. Unexpected response.';
        print('UserItemsCubit: API Response failed (status: ${response.statusCode}). Message: $errorMessage');
        emit(ActiveAdvertisementsErrorState(errorMessage));
      }
    } on DioException catch (e) {
      String errorMessage = 'Dio Active Advertisements Error: ';
      print('UserItemsCubit: ------ DioError Details Start ------');
      print('UserItemsCubit: DioError type: ${e.type}');
      print('UserItemsCubit: DioError message: ${e.message}');
      print('UserItemsCubit: DioError response status code: ${e.response?.statusCode}');
      print('UserItemsCubit: DioError response data: ${e.response?.data}');
      print('UserItemsCubit: DioError response data type: ${e.response?.data.runtimeType}');
      print('UserItemsCubit: ------ DioError Details End ------');

      if (e.response != null) {
        if (e.response!.data is Map<String, dynamic>) {
          errorMessage += e.response!.data!['message'] ?? e.response!.statusMessage ?? 'Unknown error from server response (Map).';
        } else if (e.response!.data is String) {
          errorMessage += e.response!.data.toString();
        } else {
          errorMessage += e.response!.statusMessage ?? 'Unknown error from server response (Non-Map/String data).';
        }
      } else {
        errorMessage += e.message ?? 'Network error (no response).';
      }
      print('UserItemsCubit: Emitted ActiveAdvertisementsErrorState. Error: $errorMessage');
      emit(ActiveAdvertisementsErrorState(errorMessage));
    } catch (error) {
      print('UserItemsCubit: General Active Advertisements Error: $error');
      print('UserItemsCubit: Emitted ActiveAdvertisementsErrorState. Error: ${error.toString()}');
      emit(ActiveAdvertisementsErrorState('An unexpected error occurred: ${error.toString()}'));
    }
  }
}

