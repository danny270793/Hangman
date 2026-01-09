#!/usr/bin/env dart

/// Script to seed words from JSON files to Supabase database
/// 
/// Usage:
///   dart scripts/seed_words.dart
/// 
/// This script reads words from assets/words_en.json and assets/words_es.json
/// and inserts them into the Supabase database.

import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

void main(List<String> args) async {
  print('🌱 Words Database Seeder');
  print('========================\n');

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

  // Process English words
  await seedWordsForLocale(supabase, 'en', 'assets/words_en.json');

  // Process Spanish words
  await seedWordsForLocale(supabase, 'es', 'assets/words_es.json');

  print('\n✅ Seeding complete!');
}

Future<void> seedWordsForLocale(
  SupabaseClient supabase,
  String locale,
  String jsonFilePath,
) async {
  print('📖 Processing $locale words from $jsonFilePath...');

  // Read JSON file
  final file = File(jsonFilePath);
  if (!await file.exists()) {
    print('⚠️  Warning: $jsonFilePath not found, skipping...');
    return;
  }

  final jsonString = await file.readAsString();
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;

  int totalWords = 0;
  int successfulInserts = 0;
  int skippedWords = 0;

  // Process each difficulty level
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

    print('  Processing $difficulty words (${words.length} words)...');

    for (var i = 0; i < words.length; i++) {
      final wordData = words[i] as Map<String, dynamic>;
      final word = wordData['word'] as String;
      final tags = (wordData['tags'] as List<dynamic>).map((e) => e as String).toList();

      // Calculate difficulty value based on position in the list
      // Distribute evenly across the range
      final difficultyValue = minDifficulty + ((maxDifficulty - minDifficulty) * i / words.length).round();

      try {
        // Insert or get word
        final wordId = await insertWord(supabase, word, difficultyValue, locale);
        
        if (wordId != null) {
          // Insert tags and link them
          await insertTagsAndLink(supabase, wordId, tags, locale);
          successfulInserts++;
        } else {
          skippedWords++;
        }

        totalWords++;
      } catch (e) {
        print('    ❌ Error inserting word "$word": $e');
        skippedWords++;
      }
    }
  }

  print('  ✅ $locale: $successfulInserts inserted, $skippedWords skipped (out of $totalWords total)\n');
}

Future<int?> insertWord(
  SupabaseClient supabase,
  String word,
  int difficultyValue,
  String locale,
) async {
  try {
    // Try to insert the word
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
  } on PostgrestException catch (e) {
    // If word already exists (unique constraint violation), get its ID
    if (e.code == '23505') {
      final existing = await supabase
          .from('words')
          .select('id')
          .eq('word', word)
          .eq('locale', locale)
          .single();

      return existing['id'] as int;
    }
    rethrow;
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

