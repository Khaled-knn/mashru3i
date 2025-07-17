import '../../../../../data/models/payment_method_model.dart';

abstract class PaymentMethodsState {}

class PaymentMethodsInitial extends PaymentMethodsState {}

class PaymentMethodsLoading extends PaymentMethodsState {}

class PaymentMethodsLoaded extends PaymentMethodsState {
  final List<PaymentMethod> methods;

  PaymentMethodsLoaded(this.methods);
}

class PaymentMethodsError extends PaymentMethodsState {
  final String message;

  PaymentMethodsError(this.message);
}


