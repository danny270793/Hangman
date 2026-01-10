#!/usr/bin/env dart

/// Script to sync words from JSON files to Supabase database
/// 
/// Usage:
///   dart scripts/seed_words.dart
/// 
/// This script:
/// 1. Downloads existing words, tags, and relations from Supabase
/// 2. Compares with local JSON files (assets/words_en.json, assets/words_es.json)
/// 3. Inserts new words and tags
/// 4. Updates existing words if tags changed
/// 5. Deletes words that no longer exist in local JSON

import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

class WordData {
  final String word;
  final List<String> tags;

  WordData({
    required this.word,
    required this.tags,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordData &&
          runtimeType == other.runtimeType &&
          word == other.word &&
          _listEquals(tags, other.tags);

  @override
  int get hashCode => word.hashCode ^ tags.hashCode;

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final sortedA = List<String>.from(a)..sort();
    final sortedB = List<String>.from(b)..sort();
    for (int i = 0; i < sortedA.length; i++) {
      if (sortedA[i] != sortedB[i]) return false;
    }
    return true;
  }
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
  final supabaseServiceKey = envVars['SUPABASE_SERVICE_KEY'];

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

  // Parse local words into a map (word -> tags)
  final localWords = <String, WordData>{};
  
  if (!jsonData.containsKey('words')) {
    print('⚠️  Warning: No "words" key found in $jsonFilePath, skipping...');
    return;
  }

  final wordsArray = jsonData['words'] as List<dynamic>;
  
  for (final wordJson in wordsArray) {
    final wordData = wordJson as Map<String, dynamic>;
    final word = (wordData['word'] as String).toUpperCase();
    final tags = (wordData['tags'] as List<dynamic>)
        .map((e) => e as String)
        .toList();
    
    localWords[word] = WordData(word: word, tags: tags);
  }

  print('  📊 Local: ${localWords.length} words');

  // Step 2: Download existing words from database with their tags
  print('  ⬇️  Downloading existing words from database...');
  
  final existingWords = <String, int>{}; // word -> id
  final wordIds = <int>[];
  
  // Fetch all words using pagination (1000 records per batch)
  int offset = 0;
  const int batchSize = 1000;
  
  while (true) {
      final wordsResponse = await supabase
          .from('words')
          .select('id, word')
          .eq('locale', locale)
          .range(offset, offset + batchSize - 1);
      
      if ((wordsResponse as List<dynamic>).isEmpty) {
        break;
      }
    
    for (final row in wordsResponse) {
      final word = (row['word'] as String).toUpperCase();
      final id = row['id'] as int;
      existingWords[word] = id;
      wordIds.add(id);
    }
    
    if ((wordsResponse as List<dynamic>).length < batchSize) {
      break;
    }
    
    offset += batchSize;
  }

  // Download all word-tag relationships for this locale's words
  final existingWordTags = <int, List<String>>{}; // wordId -> [tagNames]
  
  if (wordIds.isNotEmpty) {
    // Fetch word-tags in batches (Supabase .in() filter with pagination)
    // Process wordIds in chunks to avoid URL length limits
    const int chunkSize = 500;
    
    for (int i = 0; i < wordIds.length; i += chunkSize) {
      final chunk = wordIds.skip(i).take(chunkSize).toList();
      
      int offset = 0;
      const int batchSize = 1000;
      
      while (true) {
        final wordTagsResponse = await supabase
            .from('word_tags')
            .select('word_id, tags(tag)')
            .inFilter('word_id', chunk)
            .range(offset, offset + batchSize - 1);
        
        if ((wordTagsResponse as List<dynamic>).isEmpty) {
          break;
        }
        
        for (final row in wordTagsResponse) {
          final wordId = row['word_id'] as int;
          final tagInfo = row['tags'] as Map<String, dynamic>?;
          
          if (tagInfo != null && tagInfo['tag'] != null) {
            final tagName = tagInfo['tag'] as String;
            existingWordTags.putIfAbsent(wordId, () => []).add(tagName);
          }
        }
        
        if ((wordTagsResponse as List<dynamic>).length < batchSize) {
          break;
        }
        
        offset += batchSize;
      }
    }
  }

  print('  📊 Database: ${existingWords.length} words');

  // Step 3: Determine what to insert, update, and delete
  final wordsToInsert = <String>[];
  final wordsToUpdate = <String>[];
  final wordsToDelete = <String, int>{};

  // Find words to insert or update
  for (final word in localWords.keys) {
    if (!existingWords.containsKey(word)) {
      wordsToInsert.add(word);
    } else {
      // Check if tags changed
      final wordId = existingWords[word]!;
      final localTags = localWords[word]!.tags;
      final dbTags = existingWordTags[wordId] ?? [];
      
      // Compare tags
      final localTagsSet = Set<String>.from(localTags);
      final dbTagsSet = Set<String>.from(dbTags);
      
      if (!localTagsSet.difference(dbTagsSet).isEmpty ||
          !dbTagsSet.difference(localTagsSet).isEmpty) {
        wordsToUpdate.add(word);
      }
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
        
        // Insert word (difficulty_value will be auto-calculated by trigger)
        final wordResponse = await supabase
            .from('words')
            .insert({
              'word': wordData.word,
              'locale': locale,
              'difficulty_value': 50, // Default, will be recalculated by trigger
            })
            .select('id')
            .single();
        
        final wordId = wordResponse['id'] as int;
        
        // Insert tags and relationships
        await insertTagsAndLink(supabase, wordId, wordData.tags, locale);
        
        insertedCount++;
        if (insertedCount % 50 == 0) {
          stdout.write('\r     Progress: $insertedCount/${wordsToInsert.length}');
        }
      } catch (e) {
        print('\n     ❌ Error inserting "$word": $e');
      }
    }
    if (insertedCount > 0) {
      stdout.write('\r     Progress: $insertedCount/${wordsToInsert.length}\n');
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
          stdout.write('\r     Progress: $updatedCount/${wordsToUpdate.length}');
        }
      } catch (e) {
        print('\n     ❌ Error updating "$word": $e');
      }
    }
    if (updatedCount > 0) {
      stdout.write('\r     Progress: $updatedCount/${wordsToUpdate.length}\n');
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
          stdout.write('\r     Progress: $deletedCount/${wordsToDelete.length}');
        }
      } catch (e) {
        print('\n     ❌ Error deleting "${entry.key}": $e');
      }
    }
    if (deletedCount > 0) {
      stdout.write('\r     Progress: $deletedCount/${wordsToDelete.length}\n');
    }
    print('     ✅ Deleted: $deletedCount words');
  }

  // // Step 7: Clean up orphaned tags (tags not associated with any words for this locale)
  // print('  🧹 Cleaning up orphaned tags...');
  // try {
  //   // Get all tags for this locale using pagination
  //   int offset = 0;
  //   const int batchSize = 1000;
  //   int orphanedCount = 0;
    
  //   while (true) {
  //     final allTagsResponse = await supabase
  //         .from('tags')
  //         .select('id, tag')
  //         .eq('locale', locale)
  //         .range(offset, offset + batchSize - 1);
      
  //     if ((allTagsResponse as List<dynamic>).isEmpty) {
  //       break;
  //     }
      
  //     for (final tagRow in allTagsResponse) {
  //       final tagId = tagRow['id'] as int;
        
  //       // Check if this tag is associated with any words
  //       final wordTagsResponse = await supabase
  //           .from('word_tags')
  //           .select('word_id')
  //           .eq('tag_id', tagId)
  //           .limit(1);
        
  //       final count = (wordTagsResponse as List<dynamic>).length;
        
  //       if (count == 0) {
  //         await supabase.from('tags').delete().eq('id', tagId);
  //         orphanedCount++;
  //       }
  //     }
      
  //     if ((allTagsResponse as List<dynamic>).length < batchSize) {
  //       break;
  //     }
      
  //     offset += batchSize;
  //   }
    
  //   if (orphanedCount > 0) {
  //     print('     ✅ Cleaned up: $orphanedCount orphaned tags');
  //   }
  // } catch (e) {
  //   print('     ⚠️  Warning: Could not clean up orphaned tags: $e');
  // }

  print('');
  print('  ✅ $locale sync complete: ➕$insertedCount ➖$deletedCount 🔄$updatedCount\n');
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

