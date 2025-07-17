import '../../../data/models/pofession_model.dart';

abstract class ProfessionState {}

class ProfessionInitialState extends ProfessionState {}

class ProfessionLoadingState extends ProfessionState {}

class ProfessionSuccessState extends ProfessionState {
  final List<ProfessionModel> professions;
  ProfessionSuccessState(this.professions);
}

class ProfessionErrorState extends ProfessionState {
  final String error;
  ProfessionErrorState(this.error);
}
class ProfessionSelectedState extends ProfessionState {
  final ProfessionModel? selected;

  ProfessionSelectedState(this.selected);
}