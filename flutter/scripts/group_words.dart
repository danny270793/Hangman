import 'dart:convert';
import 'dart:io';
import 'package:supabase/supabase.dart';

/// Script to reorganize words by difficulty using Supabase calculation
/// 
/// This script:
/// 1. Reads words from JSON files (flat or already grouped)
/// 2. Calculates difficulty using Supabase stored procedure
/// 3. Groups words by difficulty (easy: 0-33, medium: 34-66, hard: 67-100)
/// 4. Saves back to JSON files maintaining the structure

class WordEntry {
  final String word;
  final List<String> tags;
  int? difficultyValue;

  WordEntry({
    required this.word,
    required this.tags,
    this.difficultyValue,
  });

  factory WordEntry.fromJson(Map<String, dynamic> json) {
    return WordEntry(
      word: json['word'] as String,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      difficultyValue: json['difficulty_value'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'tags': tags,
    };
  }
}

Future<void> main() async {
  print('🎯 Words Difficulty Grouping Script');
  print('====================================\n');

  // Load environment variables
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
    print('❌ Error: SUPABASE_URL or SUPABASE_SERVICE_KEY not found in .env');
    exit(1);
  }

  // Initialize Supabase client with service role key
  final supabase = SupabaseClient(supabaseUrl, supabaseServiceKey);

  print('✅ Connected to Supabase\n');

  // Process both language files
  await processLanguageFile(
    supabase,
    'assets/words_en.json',
    'en',
  );

  await processLanguageFile(
    supabase,
    'assets/words_es.json',
    'es',
  );

  print('\n✅ All files processed successfully!');
}

Future<void> processLanguageFile(
  SupabaseClient supabase,
  String filePath,
  String locale,
) async {
  print('📂 Processing: $filePath');
  print('─────────────────────────────────');

  final file = File(filePath);
  if (!await file.exists()) {
    print('⚠️  File not found: $filePath');
    return;
  }

  // Read and parse JSON
  final jsonString = await file.readAsString();
  final jsonData = json.decode(jsonString) as Map<String, dynamic>;

  // Extract all words (handle both flat and grouped structures)
  final allWords = <WordEntry>[];

  if (jsonData.containsKey('easy') || 
      jsonData.containsKey('medium') || 
      jsonData.containsKey('hard')) {
    // Already grouped structure
    for (final difficulty in ['easy', 'medium', 'hard']) {
      if (jsonData.containsKey(difficulty) && 
          jsonData[difficulty] != null &&
          jsonData[difficulty]['words'] != null) {
        final words = jsonData[difficulty]['words'] as List<dynamic>;
        for (final wordJson in words) {
          allWords.add(WordEntry.fromJson(wordJson as Map<String, dynamic>));
        }
      }
    }
  } else {
    // Flat structure (if any)
    print('⚠️  Unexpected JSON structure in $filePath');
    return;
  }

  print('📊 Found ${allWords.length} words');

  // Calculate difficulty for each word
  print('🔢 Calculating difficulties...');
  
  final easyWords = <WordEntry>[];
  final mediumWords = <WordEntry>[];
  final hardWords = <WordEntry>[];

  var processed = 0;
  final total = allWords.length;

  for (final wordEntry in allWords) {
    try {
      // Call Supabase function to calculate difficulty
      final result = await supabase.rpc(
        'calculate_word_difficulty',
        params: {
          'word_text': wordEntry.word,
          'word_locale': locale,
        },
      );

      // Convert 0-1 scale to 0-100
      final difficultyDecimal = result as double;
      final difficultyValue = (difficultyDecimal * 100).round();
      
      wordEntry.difficultyValue = difficultyValue;

      // Categorize by difficulty
      if (difficultyValue <= 33) {
        easyWords.add(wordEntry);
      } else if (difficultyValue <= 66) {
        mediumWords.add(wordEntry);
      } else {
        hardWords.add(wordEntry);
      }

      processed++;
      if (processed % 50 == 0) {
        print('   Progress: $processed/$total words');
      }
    } catch (e) {
      print('⚠️  Error calculating difficulty for "${wordEntry.word}": $e');
      // Default to medium if calculation fails
      mediumWords.add(wordEntry);
    }
  }

  print('   Progress: $processed/$total words');
  print('');
  print('📈 Difficulty Distribution:');
  print('   Easy (0-33):     ${easyWords.length} words');
  print('   Medium (34-66):  ${mediumWords.length} words');
  print('   Hard (67-100):   ${hardWords.length} words');

  // Create new JSON structure
  final newJsonData = {
    'easy': {
      'words': easyWords.map((w) => w.toJson()).toList(),
    },
    'medium': {
      'words': mediumWords.map((w) => w.toJson()).toList(),
    },
    'hard': {
      'words': hardWords.map((w) => w.toJson()).toList(),
    },
  };

  // Save back to file with pretty formatting
  final encoder = JsonEncoder.withIndent('  ');
  final prettyJson = encoder.convert(newJsonData);
  await file.writeAsString('$prettyJson\n');

  print('💾 Saved updated file: $filePath');
  print('');
}

