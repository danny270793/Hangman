import 'package:equatable/equatable.dart';

abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {
  const RegisterInitial();
}

class RegisterLoading extends RegisterState {
  const RegisterLoading();
}

class RegisterSuccess extends RegisterState {
  final String email;

  const RegisterSuccess(this.email);

  @override
  List<Object?> get props => [email];
}

class RegisterFailure extends RegisterState {
  /// Backend message, or `null` for an unexpected error.
  final String? message;

  const RegisterFailure(this.message);

  @override
  List<Object?> get props => [message];
}
