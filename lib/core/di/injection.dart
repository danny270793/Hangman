import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../difficulty/app_difficulty_controller.dart';
import '../locale/app_locale_controller.dart';
import '../security/app_biometric_unlock_controller.dart';
import '../theme/app_theme_controller.dart';
import '../timed_mode/app_timed_mode_controller.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/update_email_usecase.dart';
import '../../features/auth/domain/usecases/update_password_usecase.dart';
import '../../features/auth/domain/usecases/update_username_usecase.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/auth/presentation/cubit/settings_cubit.dart';
import '../../features/game/data/datasources/game_records_remote_datasource.dart';
import '../../features/game/data/datasources/words_remote_datasource.dart';
import '../../features/game/data/repositories/game_records_repository_impl.dart';
import '../../features/game/data/repositories/words_repository_impl.dart';
import '../../features/game/domain/repositories/game_records_repository.dart';
import '../../features/game/domain/repositories/words_repository.dart';
import '../../features/game/domain/usecases/get_game_records_usecase.dart';
import '../../features/game/domain/usecases/get_words_usecase.dart';
import '../../features/game/domain/usecases/pick_random_word_usecase.dart';
import '../../features/game/domain/usecases/save_game_record_usecase.dart';
import '../../features/game/presentation/cubit/game_cubit.dart';
import '../../features/game/presentation/cubit/records_cubit.dart';

final getIt = GetIt.instance;

void setupDi() {
  getIt.registerLazySingleton<AppLocaleController>(AppLocaleController.new);
  getIt.registerLazySingleton<AppThemeController>(AppThemeController.new);
  getIt.registerLazySingleton<AppBiometricUnlockController>(
    AppBiometricUnlockController.new,
  );
  getIt.registerLazySingleton<AppDifficultyController>(
    AppDifficultyController.new,
  );
  getIt.registerLazySingleton<AppTimedModeController>(
    AppTimedModeController.new,
  );

  // auth
  getIt.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthSupabaseDatasource(Supabase.instance.client),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDatasource>()),
  );
  getIt.registerFactory<GetCurrentUserUsecase>(
    () => GetCurrentUserUsecase(getIt()),
  );
  getIt.registerFactory<SignInUsecase>(() => SignInUsecase(getIt()));
  getIt.registerFactory<SignUpUsecase>(() => SignUpUsecase(getIt()));
  getIt.registerFactory<SignOutUsecase>(() => SignOutUsecase(getIt()));
  getIt.registerFactory<UpdateEmailUsecase>(() => UpdateEmailUsecase(getIt()));
  getIt.registerFactory<UpdatePasswordUsecase>(
    () => UpdatePasswordUsecase(getIt()),
  );
  getIt.registerFactory<UpdateUsernameUsecase>(
    () => UpdateUsernameUsecase(getIt()),
  );
  getIt.registerFactory<LoginBloc>(() => LoginBloc(signIn: getIt()));
  getIt.registerFactory<RegisterCubit>(() => RegisterCubit(signUp: getIt()));
  getIt.registerFactory<SettingsCubit>(() => SettingsCubit(signOut: getIt()));

  // game
  getIt.registerLazySingleton<WordsRemoteDatasource>(
    () => WordsSupabaseDatasource(Supabase.instance.client),
  );
  getIt.registerLazySingleton<WordsRepository>(
    () => WordsRepositoryImpl(getIt<WordsRemoteDatasource>()),
  );
  getIt.registerLazySingleton<GameRecordsRemoteDatasource>(
    () => GameRecordsSupabaseDatasource(Supabase.instance.client),
  );
  getIt.registerLazySingleton<GameRecordsRepository>(
    () => GameRecordsRepositoryImpl(getIt<GameRecordsRemoteDatasource>()),
  );
  getIt.registerFactory<GetWordsUsecase>(() => GetWordsUsecase(getIt()));
  getIt.registerFactory<PickRandomWordUsecase>(
    () => const PickRandomWordUsecase(),
  );
  getIt.registerFactory<SaveGameRecordUsecase>(
    () => SaveGameRecordUsecase(getIt()),
  );
  getIt.registerFactory<GetGameRecordsUsecase>(
    () => GetGameRecordsUsecase(getIt()),
  );
  getIt.registerFactory<GameCubit>(
    () => GameCubit(
      getWords: getIt(),
      pickRandomWord: getIt(),
      saveGameRecord: getIt(),
    ),
  );
  getIt.registerFactory<RecordsCubit>(
    () => RecordsCubit(getGameRecords: getIt()),
  );
}
