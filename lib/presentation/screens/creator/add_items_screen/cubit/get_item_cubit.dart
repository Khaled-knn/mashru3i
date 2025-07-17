import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/local/cach_helper.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import '../../../../../data/models/items_model/creator_item_model.dart';
import 'get_item_state.dart'; // Make sure this file exists and states are updated

class GetItemsCubit extends Cubit<GetItemsState> {
  GetItemsCubit() : super(GetItemsInitial());

  // Function to fetch items
  Future<void> fetchMyItems() async {
    emit(GetItemsLoading());
    String? token = CacheHelper.getData(key: 'token');
    if (token == null) {
      emit(GetItemsFailure('Authentication token not found. Please log in.'));
      return;
    }
    try {
      final response = await DioHelper.getData(
        url: GET_MY_ITEMS,
        token: 'Bearer $token',
      );



      print('--- Start fetchMyItems Response Debug ---');
      print('API Response Status Code: ${response.statusCode}');
      print('API Raw Response Data Type: ${response.data.runtimeType}');
      print('API Raw Response Data (partial, avoid logging too much sensitive data):');
      if (response.data != null) {
        String dataPreview = response.data.toString();
        if (dataPreview.length > 500) {
          print(dataPreview.substring(0, 500) + '...');
        } else {
          print(dataPreview);
        }
      } else {
        print('API Raw Response Data: null');
      }
      print('--- End fetchMyItems Response Debug ---');


      dynamic parsedData;

      if (response.data is String) {
        try {
          parsedData = json.decode(response.data);
          print('Response was a String, successfully JSON decoded.');
        } catch (e) {
          print('Error: API returned a String that is NOT valid JSON. Content: "${response.data}". Error: $e');
          emit(GetItemsFailure('API returned an error message: ${response.data}'));
          return;
        }
      } else {
        parsedData = response.data;
        print('Response was already parsed (Map or List). Type: ${parsedData.runtimeType}');
      }

      List<dynamic> itemsJsonList = [];

      if (parsedData == null) {
        print('Error: Parsed data is null.');
        emit(GetItemsFailure('Failed to fetch items: API response is empty or null.'));
        return;
      } else if (parsedData is Map<String, dynamic>) {
        if (parsedData.containsKey('items') && parsedData['items'] is List) {
          itemsJsonList = parsedData['items'] as List;
          print('Successfully extracted "items" list from Map.');
        } else {
          print('Error: API response is a Map but does not contain a "items" list.');
          emit(GetItemsFailure('Failed to parse items: Missing "items" list in response.'));
          return;
        }
      } else if (parsedData is List) {
        itemsJsonList = parsedData;
        print('Successfully treated response as direct List of items.');
      } else {
        print('Error: Unexpected data structure after parsing. Type: ${parsedData.runtimeType}.');
        emit(GetItemsFailure('Failed to fetch items: Unexpected data structure from API.'));
        return;
      }
      final List<CreatorItemModel> items = [];
      for (var itemJson in itemsJsonList) {
        if (itemJson is Map<String, dynamic>) {
          try {
            items.add(CreatorItemModel.fromJson(itemJson));
          } catch (e) {
            print('Warning: Failed to parse single item JSON. Skipping item. Error: $e, Item JSON: $itemJson');
          }
        } else {
          print('Warning: Skipping item because it is not a Map<String, dynamic>. Type: ${itemJson.runtimeType}, Value: $itemJson');
        }
      }

      if (items.isEmpty && itemsJsonList.isNotEmpty) {
        print('Warning: No items were successfully parsed despite having data in the response.');
      }

      emit(GetItemsSuccess(items));

    } on DioException catch (e) {
      print('Dio Error in fetchMyItems:');
      print('  Status Code: ${e.response?.statusCode}');
      print('  Response Data Type: ${e.response?.data.runtimeType}');
      print('  Response Data: ${e.response?.data}');
      print('  Error Message: ${e.message}');

      String errorMessage = 'Network or server error: ${e.message ?? 'Unknown Dio error'}';
      if (e.response != null && e.response!.data != null) {
        try {
          final errorData = e.response!.data;
          if (errorData is String) {
            errorMessage = 'Server error: $errorData';
          } else if (errorData is Map && errorData.containsKey('message')) {
            errorMessage = 'Server error: ${errorData['message']}';
          }
        } catch (_) {
        }
      }
      emit(GetItemsFailure(errorMessage));
    } catch (e) {
      print('Generic Error in fetchMyItems: $e');
      emit(GetItemsFailure('Failed to fetch items: ${e.toString()}'));
    }
  }


  Future<void> updateItem({
    required int itemId,
    required Map<String, dynamic> itemData,
  }) async {
    emit(GetItemsLoading());
    String? token = CacheHelper.getData(key: 'token');
    if (token == null) {
      emit(GetItemsFailure(LocaleKeys.authenticationTokenNotFound.tr()));
      return;
    }
    try {
      final response = await DioHelper.updateData(
        url: '$UPDATE_ITEM/$itemId',
        data: itemData,
        token: 'Bearer $token',
      );

      print('Update Item API Raw Response: ${response.data}');
      print('Update Item API Status Code: ${response.statusCode}');
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        await fetchMyItems();
        final String message = response.data['message'] ?? LocaleKeys.itemUpdatedSuccessfully.tr();
        final int tokensDeducted = response.data['tokensDeducted'] ?? 0;

        emit(UpdateItemSuccess(message, tokensDeducted));
      } else {
        final String errorMessage = response.data['message'] ?? response.data['error'] ?? LocaleKeys.failedToUpdateItem.tr();
        emit(GetItemsFailure(errorMessage));
      }
    } on DioException catch (e) {
      final errorMessage = _handleUpdateError(e);
      emit(GetItemsFailure(errorMessage));
    } catch (e) {
      emit(GetItemsFailure(LocaleKeys.unexpectedErrorOccurred.tr(namedArgs: {'error': e.toString()})));
    }
  }

  String _handleUpdateError(DioException e) {
    String errorMessage = LocaleKeys.failedToUpdateItem.tr();
    if (e.response != null) {
      print('DioError response data: ${e.response?.data}');
      print('DioError status code: ${e.response?.statusCode}');

      if (e.response?.data is Map && e.response?.data.containsKey('message')) {
        errorMessage = e.response?.data['message'];
      } else if (e.response?.data is Map && e.response?.data.containsKey('error')) {
        errorMessage = e.response?.data['error'];
      } else {
        errorMessage = 'Error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      }
    } else {
      errorMessage = LocaleKeys.networkError.tr();
    }
    return errorMessage;
  }

  Future<void> deleteItem(int itemId) async {
    emit(GetItemsLoading());
    String? token = CacheHelper.getData(key: 'token');
    if (token == null) {
      emit(GetItemsFailure('Authentication token not found. Cannot delete item.'));
      return;
    }
    try {
      await DioHelper.deleteData(
        url: '$DELETE_ITEM/$itemId',
        token: 'Bearer $token',
      );

      await fetchMyItems();

      emit(DeleteItemSuccess('Item deleted successfully.'));
    } on DioException catch (e) {
      final errorMessage = _handleDeleteError(e);
      emit(GetItemsFailure(errorMessage));
    } catch (e) {
      emit(GetItemsFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }


  String _handleDeleteError(DioException e) {
    print('Delete Error Response: ${e.response?.data}');
    switch (e.response?.statusCode) {
      case 403:
        return e.response?.data['error'] ?? 'Unauthorized to delete item.';
      case 404:
        return 'Item not found.';
      case 401:
        return 'Unauthorized to delete. Please log in again.';
      default:
        return 'Failed to delete item: ${e.response?.data['error'] ?? e.message}';
    }
  }


}