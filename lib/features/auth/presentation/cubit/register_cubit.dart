import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/logger/app_logger.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final SignUpUsecase _signUp;

  RegisterCubit({required this._signUp}) : super(const RegisterInitial());

  Future<void> register({
    required String email,
    required String password,
    String? username,
  }) async {
    AppLogger.debug('sign up submitted');
    emit(const RegisterLoading());
    try {
      await _signUp(email: email, password: password, username: username);
      AppLogger.info('sign up success');
      emit(RegisterSuccess(email));
    } on AuthException catch (e) {
      AppLogger.warn('sign up failed — ${e.message}');
      emit(RegisterFailure(e.message));
    } catch (e, s) {
      AppLogger.error('unexpected error during sign up', e, s);
      emit(const RegisterFailure(null));
    }
  }
}
