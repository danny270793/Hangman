#!/usr/bin/env dart

/// Script to sync words from JSON files to Supabase database
/// 
/// Usage:
///   dart scripts/seed_words.dart
/// 
/// This script:
/// 1. Downloads existing words from Supabase for the locale
/// 2. Compares with local JSON files
/// 3. Inserts missing words
/// 4. Deletes words that no longer exist in JSON
/// 5. Updates tags for existing words

import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

class WordData {
  final String word;
  final List<String> tags;
  final int difficultyValue;

  WordData({
    required this.word,
    required this.tags,
    required this.difficultyValue,
  });
}

void main(List<String> args) async {
  print('🔄 Words Database Sync');
  print('======================\n');

  // Load environment variables from .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Error: .env file not found');
    print('   Create a .env file with SUPABASE_URL and SUPABASE_SERVICE_KEY');
    exit(1);
  }

  final envContent = await envFile.readAsString();
  final envVars = <String, String>{};
  
  for (final line in envContent.split('\n')) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    
    final parts = trimmed.split('=');
    if (parts.length >= 2) {
      final key = parts[0].trim();
      final value = parts.sublist(1).join('=').trim();
      envVars[key] = value;
    }
  }

  final supabaseUrl = envVars['SUPABASE_URL'];
  final supabaseServiceKey = envVars['SUPABASE_SERVICE_KEY']; // Use service key for admin operations

  if (supabaseUrl == null || supabaseServiceKey == null) {
    print('❌ Error: SUPABASE_URL or SUPABASE_SERVICE_KEY not found in .env file');
    print('   Make sure you have a .env file with these variables.');
    exit(1);
  }

  // Initialize Supabase client with service role key
  final supabase = SupabaseClient(supabaseUrl, supabaseServiceKey);

  // Sync English words
  await syncWordsForLocale(supabase, 'en', 'assets/words_en.json');

  // Sync Spanish words
  await syncWordsForLocale(supabase, 'es', 'assets/words_es.json');

  print('\n✅ Sync complete!');
}

Future<void> syncWordsForLocale(
  SupabaseClient supabase,
  String locale,
  String jsonFilePath,
) async {
  print('📖 Syncing $locale words from $jsonFilePath...');

  // Step 1: Read local JSON file
  final file = File(jsonFilePath);
  if (!await file.exists()) {
    print('⚠️  Warning: $jsonFilePath not found, skipping...');
    return;
  }

  final jsonString = await file.readAsString();
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;

  // Parse local words into a map
  final localWords = <String, WordData>{};
  final difficulties = ['easy', 'medium', 'hard'];
  final difficultyRanges = {
    'easy': {'min': 1, 'max': 33},
    'medium': {'min': 34, 'max': 66},
    'hard': {'min': 67, 'max': 100},
  };

  for (final difficulty in difficulties) {
    if (!jsonData.containsKey(difficulty)) continue;

    final difficultyData = jsonData[difficulty] as Map<String, dynamic>?;
    if (difficultyData == null || !difficultyData.containsKey('words')) {
      continue;
    }

    final words = difficultyData['words'] as List<dynamic>;
    final minDifficulty = difficultyRanges[difficulty]!['min']!;
    final maxDifficulty = difficultyRanges[difficulty]!['max']!;

    for (var i = 0; i < words.length; i++) {
      final wordData = words[i] as Map<String, dynamic>;
      final word = (wordData['word'] as String).toUpperCase();
      final tags = (wordData['tags'] as List<dynamic>).map((e) => e as String).toList();
      
      // Calculate difficulty value based on position in the list
      final difficultyValue = minDifficulty + ((maxDifficulty - minDifficulty) * i / words.length).round();

      localWords[word] = WordData(
        word: word,
        tags: tags,
        difficultyValue: difficultyValue,
      );
    }
  }

  print('  📊 Local: ${localWords.length} words');

  // Step 2: Download existing words from database
  print('  ⬇️  Downloading existing words from database...');
  final existingWordsResponse = await supabase
      .from('words')
      .select('id, word')
      .eq('locale', locale);

  final existingWords = <String, int>{}; // word -> id
  for (final row in existingWordsResponse as List<dynamic>) {
    final word = (row['word'] as String).toUpperCase();
    final id = row['id'] as int;
    existingWords[word] = id;
  }

  print('  📊 Database: ${existingWords.length} words');

  // Step 3: Determine what to insert, update, and delete
  final wordsToInsert = <String>[];
  final wordsToUpdate = <String>[];
  final wordsToDelete = <String, int>{};

  // Find words to insert (in local but not in database)
  for (final word in localWords.keys) {
    if (!existingWords.containsKey(word)) {
      wordsToInsert.add(word);
    } else {
      wordsToUpdate.add(word);
    }
  }

  // Find words to delete (in database but not in local)
  for (final entry in existingWords.entries) {
    if (!localWords.containsKey(entry.key)) {
      wordsToDelete[entry.key] = entry.value;
    }
  }

  print('');
  print('  📈 Analysis:');
  print('     ➕ To insert: ${wordsToInsert.length}');
  print('     🔄 To update: ${wordsToUpdate.length}');
  print('     ➖ To delete: ${wordsToDelete.length}');
  print('');

  // Step 4: Insert new words
  int insertedCount = 0;
  if (wordsToInsert.isNotEmpty) {
    print('  ➕ Inserting new words...');
    for (final word in wordsToInsert) {
      try {
        final wordData = localWords[word]!;
        final wordId = await insertWord(
          supabase,
          wordData.word,
          wordData.difficultyValue,
          locale,
        );
        
        if (wordId != null) {
          await insertTagsAndLink(supabase, wordId, wordData.tags, locale);
          insertedCount++;
          if (insertedCount % 50 == 0) {
            print('     Progress: $insertedCount/${wordsToInsert.length}');
          }
        }
      } catch (e) {
        print('     ❌ Error inserting "$word": $e');
      }
    }
    print('     ✅ Inserted: $insertedCount words');
  }

  // Step 5: Update existing words (tags)
  int updatedCount = 0;
  if (wordsToUpdate.isNotEmpty) {
    print('  🔄 Updating existing words...');
    for (final word in wordsToUpdate) {
      try {
        final wordId = existingWords[word]!;
        final wordData = localWords[word]!;
        
        // Delete old tag associations
        await supabase
            .from('word_tags')
            .delete()
            .eq('word_id', wordId);
        
        // Insert new tags
        await insertTagsAndLink(supabase, wordId, wordData.tags, locale);
        updatedCount++;
        
        if (updatedCount % 50 == 0) {
          print('     Progress: $updatedCount/${wordsToUpdate.length}');
        }
      } catch (e) {
        print('     ❌ Error updating "$word": $e');
      }
    }
    print('     ✅ Updated: $updatedCount words');
  }

  // Step 6: Delete removed words
  int deletedCount = 0;
  if (wordsToDelete.isNotEmpty) {
    print('  ➖ Deleting removed words...');
    for (final entry in wordsToDelete.entries) {
      try {
        // Delete word (cascades to word_tags due to ON DELETE CASCADE)
        await supabase
            .from('words')
            .delete()
            .eq('id', entry.value);
        deletedCount++;
        
        if (deletedCount % 50 == 0) {
          print('     Progress: $deletedCount/${wordsToDelete.length}');
        }
      } catch (e) {
        print('     ❌ Error deleting "${entry.key}": $e');
      }
    }
    print('     ✅ Deleted: $deletedCount words');
  }

  print('');
  print('  ✅ $locale sync complete: ➕$insertedCount ➖$deletedCount 🔄$updatedCount\n');
}

Future<int?> insertWord(
  SupabaseClient supabase,
  String word,
  int difficultyValue,
  String locale,
) async {
  try {
    // Insert the word
    final response = await supabase
        .from('words')
        .insert({
          'word': word,
          'difficulty_value': difficultyValue,
          'locale': locale,
        })
        .select('id')
        .single();

    return response['id'] as int;
  } catch (e) {
    // Log error and return null
    print('       Error inserting word: $e');
    return null;
  }
}

Future<void> insertTagsAndLink(
  SupabaseClient supabase,
  int wordId,
  List<String> tags,
  String locale,
) async {
  for (final tag in tags) {
    try {
      // Insert or get tag
      late int tagId;
      try {
        final response = await supabase
            .from('tags')
            .insert({
              'tag': tag,
              'locale': locale,
            })
            .select('id')
            .single();

        tagId = response['id'] as int;
      } on PostgrestException catch (e) {
        // If tag already exists, get its ID
        if (e.code == '23505') {
          final existing = await supabase
              .from('tags')
              .select('id')
              .eq('tag', tag)
              .eq('locale', locale)
              .single();

          tagId = existing['id'] as int;
        } else {
          rethrow;
        }
      }

      // Link word to tag (ignore if already linked)
      try {
        await supabase
            .from('word_tags')
            .insert({
              'word_id': wordId,
              'tag_id': tagId,
            });
      } on PostgrestException catch (e) {
        // Ignore duplicate key errors (already linked)
        if (e.code != '23505') {
          rethrow;
        }
      }
    } catch (e) {
      print('      ⚠️  Warning: Could not insert tag "$tag": $e');
    }
  }
}

