import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_game_records_usecase.dart';
import 'records_state.dart';

class RecordsCubit extends Cubit<RecordsState> {
  static const int pageSize = 10;

  final GetGameRecordsUsecase _getGameRecords;
  int _offset = 0;

  RecordsCubit({required this._getGameRecords}) : super(const RecordsState());

  Future<void> load() async {
    _offset = 0;
    emit(state.copyWith(isLoading: true, hasMore: true));
    final records = await _getGameRecords(limit: pageSize, offset: 0);
    if (isClosed) return;
    emit(
      RecordsState(
        records: records,
        isLoading: false,
        hasMore: records.length == pageSize,
      ),
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    emit(state.copyWith(isLoadingMore: true));
    _offset += pageSize;
    final next = await _getGameRecords(limit: pageSize, offset: _offset);
    if (isClosed) return;
    emit(
      state.copyWith(
        records: [...state.records, ...next],
        isLoadingMore: false,
        hasMore: next.length == pageSize,
      ),
    );
  }
}
