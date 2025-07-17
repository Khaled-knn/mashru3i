import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mashrou3i/presentation/screens/creator/add_items_screen/cubit/get_item_cubit.dart';
import '../../../../../core/network/end_pointes/end_poines.dart';
import '../../../../../core/network/remote/dio.dart';
import '../../../../../core/theme/LocaleKeys.dart';
import 'add_item_state.dart';


class ItemCubit extends Cubit<ItemState> {
  ItemCubit() : super(ItemInitial());


  Future<void> addItem({
    required Map<String, dynamic> itemData,
    required String token,
    required BuildContext context,
  }) async {
    emit(ItemLoading());

    itemData.removeWhere((key, value) => value == null);

    print('FINAL ITEM DATA TO SEND: ${jsonEncode(itemData)}');

    try {
      final response = await DioHelper.postData(
        url: ADD_ITEMS,
        data: itemData,
        token: 'Bearer $token',
      );

      if (response.statusCode == 201) {
        emit(ItemSuccess(response.data['itemId'] , LocaleKeys.successAdd.tr()));
        context.read<GetItemsCubit>().fetchMyItems();

      } else {
        emit(ItemFailure(response.data['error'] ?? 'Failed to add item'));
      }
    } catch (e) {
      print('ERROR DETAILS: $e');
      if (e is DioException) {
        print('RESPONSE DATA: ${e.response?.data}');
        print('STATUS CODE: ${e.response?.statusCode}');
      }
      print(e.toString());
      emit(ItemFailure('you need 5 coins to add new item'));
    }
  }

}

