import 'package:flutter/material.dart';
import 'package:hangman/l10n/app_localizations.dart';
import 'package:hangman/services/game_record_service.dart';

class RecordsPage extends StatefulWidget {
  static const String routeName = '/records';

  const RecordsPage({super.key});

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final GameRecordService _gameRecordService = GameRecordService();
  List<Map<String, dynamic>> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
    });

    final records = await _gameRecordService.getAllGameRecords(limit: 100);

    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  String _getDifficultyText(String difficulty, AppLocalizations l10n) {
    switch (difficulty) {
      case 'easy':
        return l10n.easy;
      case 'medium':
        return l10n.medium;
      case 'hard':
        return l10n.hard;
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.gameRecords)),
      body: RefreshIndicator(
        onRefresh: _loadRecords,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _records.isEmpty
            ? ListView(
                // Wrap in ListView to enable pull-to-refresh on empty state
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height - 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events_outlined,
                            size: 80,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.noRecordsYet,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _records.length,
                itemBuilder: (context, index) {
                  final record = _records[index];
                  final rank = index + 1;
                  final username = record['username'] as String? ?? 'Player';
                  final points = record['points'] as int;
                  final words = record['words'] as int;
                  final time = record['time_playing'] as int;
                  final difficulty = record['difficulty'] as String;
                  final hasTimedMode = record['has_timed_mode_enabled'] as bool;

                  return SafeArea(
                    top: false,
                    left: true,
                    right: true,
                    bottom: false,
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: rank <= 3 ? 4 : 2,
                      child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: rank <= 3
                            ? LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  _getRankColor(rank).withOpacity(0.1),
                                  Colors.transparent,
                                ],
                              )
                            : null,
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: _buildRankBadge(rank),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                username,
                                style: TextStyle(
                                  fontWeight: rank <= 3
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(difficulty),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getDifficultyText(difficulty, l10n),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              _buildStatChip(
                                Icons.star,
                                '$points ${l10n.points}',
                                Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                Icons.check_circle,
                                '$words ${l10n.wordsSolved}',
                                Colors.green,
                              ),
                              const SizedBox(width: 8),
                              _buildStatChip(
                                hasTimedMode ? Icons.timer : Icons.access_time,
                                '${time}s',
                                hasTimedMode ? Colors.orange : Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    IconData icon;
    Color color;

    if (rank == 1) {
      icon = Icons.emoji_events;
      color = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      icon = Icons.emoji_events;
      color = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      icon = Icons.emoji_events;
      color = const Color(0xFFCD7F32); // Bronze
    } else {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$rank',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 32),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700);
    if (rank == 2) return const Color(0xFFC0C0C0);
    if (rank == 3) return const Color(0xFFCD7F32);
    return Colors.grey;
  }

  Widget _buildStatChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
