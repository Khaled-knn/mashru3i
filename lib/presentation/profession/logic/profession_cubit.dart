import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/remote/dio.dart';
import '../../../data/models/pofession_model.dart';
import 'profession_state.dart';

class ProfessionCubit extends Cubit<ProfessionState> {
  ProfessionCubit() : super(ProfessionInitialState());

  static ProfessionCubit get(context) => BlocProvider.of(context);

  List<ProfessionModel> professionList = [];
  ProfessionModel? selectedProfession;

  void getProfessions() {
    emit(ProfessionLoadingState());

    DioHelper.getData(url:'/api/professions').then((value) {
      professionList = (value.data as List)
          .map((e) => ProfessionModel.fromJson(e))
          .toList();
      print("Selected profession: ${selectedProfession?.toJson()}");
      print("Selected profession id: ${selectedProfession?.id}");
      emit(ProfessionSuccessState(professionList));
    }).catchError((error) {
      emit(ProfessionErrorState(error.toString()));
      print('Error fetching professions: $error');
      if (error is DioError) {
        print('Response data: ${error.response?.data}');
        print('Status code: ${error.response?.statusCode}');
      }
      emit(ProfessionErrorState(error.toString()));
    });
  }

  void selectProfession(ProfessionModel? profession) {
    selectedProfession = profession;
    emit(ProfessionSelectedState(profession));
  }
}

