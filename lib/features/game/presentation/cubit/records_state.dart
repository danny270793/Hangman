import 'package:equatable/equatable.dart';

import '../../domain/entities/game_record_entity.dart';

class RecordsState extends Equatable {
  final List<GameRecordEntity> records;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  const RecordsState({
    this.records = const [],
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
  });

  RecordsState copyWith({
    List<GameRecordEntity>? records,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
  }) => RecordsState(
    records: records ?? this.records,
    isLoading: isLoading ?? this.isLoading,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  List<Object?> get props => [records, isLoading, isLoadingMore, hasMore];
}
