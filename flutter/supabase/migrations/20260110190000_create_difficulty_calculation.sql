-- Create a function to calculate word difficulty (0-1 scale)
-- Based on: unique letters, word length, and letter frequency by language

-- Letter frequency tables (normalized 0-1, where 1 = most common, 0 = least common)
CREATE TABLE IF NOT EXISTS public.letter_frequencies (
    letter CHAR(1) NOT NULL,
    locale TEXT NOT NULL,
    frequency NUMERIC(3,2) NOT NULL CHECK (frequency >= 0 AND frequency <= 1),
    PRIMARY KEY (letter, locale)
);

-- Insert English letter frequencies (based on general usage)
INSERT INTO public.letter_frequencies (letter, locale, frequency) VALUES
    ('E', 'en', 1.00), ('T', 'en', 0.91), ('A', 'en', 0.82), ('O', 'en', 0.75),
    ('I', 'en', 0.70), ('N', 'en', 0.67), ('S', 'en', 0.63), ('H', 'en', 0.61),
    ('R', 'en', 0.60), ('D', 'en', 0.43), ('L', 'en', 0.40), ('C', 'en', 0.28),
    ('U', 'en', 0.28), ('M', 'en', 0.24), ('W', 'en', 0.24), ('F', 'en', 0.22),
    ('G', 'en', 0.20), ('Y', 'en', 0.20), ('P', 'en', 0.19), ('B', 'en', 0.15),
    ('V', 'en', 0.10), ('K', 'en', 0.08), ('J', 'en', 0.02), ('X', 'en', 0.02),
    ('Q', 'en', 0.01), ('Z', 'en', 0.01)
ON CONFLICT (letter, locale) DO UPDATE SET frequency = EXCLUDED.frequency;

-- Insert Spanish letter frequencies (based on general usage)
INSERT INTO public.letter_frequencies (letter, locale, frequency) VALUES
    ('E', 'es', 1.00), ('A', 'es', 0.95), ('O', 'es', 0.87), ('S', 'es', 0.80),
    ('R', 'es', 0.75), ('N', 'es', 0.71), ('I', 'es', 0.63), ('D', 'es', 0.58),
    ('L', 'es', 0.52), ('C', 'es', 0.47), ('T', 'es', 0.46), ('U', 'es', 0.45),
    ('M', 'es', 0.32), ('P', 'es', 0.28), ('B', 'es', 0.14), ('G', 'es', 0.10),
    ('V', 'es', 0.09), ('Y', 'es', 0.09), ('Q', 'es', 0.09), ('H', 'es', 0.07),
    ('F', 'es', 0.07), ('Z', 'es', 0.05), ('J', 'es', 0.04), ('Ñ', 'es', 0.03),
    ('X', 'es', 0.02), ('W', 'es', 0.00), ('K', 'es', 0.00)
ON CONFLICT (letter, locale) DO UPDATE SET frequency = EXCLUDED.frequency;

-- Function to calculate difficulty for a single word
CREATE OR REPLACE FUNCTION calculate_word_difficulty(
    word_text TEXT,
    word_locale TEXT DEFAULT 'en'
)
RETURNS NUMERIC AS $$
DECLARE
    word_upper TEXT;
    word_length INT;
    unique_letters INT;
    unique_ratio NUMERIC;
    letter CHAR(1);
    letter_score NUMERIC := 0;
    avg_letter_frequency NUMERIC;
    length_score NUMERIC;
    final_difficulty NUMERIC;
BEGIN
    -- Normalize word to uppercase
    word_upper := UPPER(word_text);
    word_length := LENGTH(word_upper);
    
    -- Calculate unique letters
    SELECT COUNT(DISTINCT letter_char) INTO unique_letters
    FROM regexp_split_to_table(word_upper, '') AS letter_char
    WHERE letter_char ~ '[A-ZÑÁÉÍÓÚÜ]';
    
    -- Calculate unique letter ratio (0-1)
    IF word_length > 0 THEN
        unique_ratio := unique_letters::NUMERIC / word_length::NUMERIC;
    ELSE
        unique_ratio := 0;
    END IF;
    
    -- Calculate average letter rarity (inverse of frequency)
    -- Rare letters = higher difficulty
    SELECT COALESCE(AVG(1.0 - COALESCE(lf.frequency, 0.5)), 0.5) INTO avg_letter_frequency
    FROM regexp_split_to_table(word_upper, '') AS letter_char
    LEFT JOIN public.letter_frequencies lf 
        ON lf.letter = letter_char AND lf.locale = word_locale
    WHERE letter_char ~ '[A-ZÑÁÉÍÓÚÜ]';
    
    -- Calculate length score (normalized, with diminishing returns after 10 letters)
    -- Shorter words (3-5 letters) = easier (0.2-0.4)
    -- Medium words (6-8 letters) = medium (0.4-0.6)
    -- Longer words (9+ letters) = harder (0.6-1.0)
    length_score := LEAST(1.0, (word_length::NUMERIC - 3.0) / 12.0);
    length_score := GREATEST(0.0, length_score);
    
    -- Combine factors with weights:
    -- - 40% unique letter ratio (more unique = harder)
    -- - 35% letter rarity (rare letters = harder)
    -- - 25% length (longer = harder)
    final_difficulty := (
        (unique_ratio * 0.40) +
        (avg_letter_frequency * 0.35) +
        (length_score * 0.25)
    );
    
    -- Ensure result is between 0 and 1
    final_difficulty := LEAST(1.0, GREATEST(0.0, final_difficulty));
    
    RETURN final_difficulty;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Stored procedure to update difficulty_value for all words
CREATE OR REPLACE FUNCTION update_all_word_difficulties()
RETURNS TABLE(updated_count INT) AS $$
DECLARE
    affected_rows INT := 0;
BEGIN
    -- Update all words with calculated difficulty
    UPDATE public.words w
    SET difficulty_value = ROUND(calculate_word_difficulty(w.word, w.locale)::NUMERIC * 100)
    WHERE w.difficulty_value IS NULL 
       OR w.difficulty_value != ROUND(calculate_word_difficulty(w.word, w.locale)::NUMERIC * 100);
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RETURN QUERY SELECT affected_rows;
END;
$$ LANGUAGE plpgsql;

-- Stored procedure to update difficulty for a specific locale
CREATE OR REPLACE FUNCTION update_word_difficulties_by_locale(
    target_locale TEXT
)
RETURNS TABLE(updated_count INT) AS $$
DECLARE
    affected_rows INT := 0;
BEGIN
    UPDATE public.words w
    SET difficulty_value = ROUND(calculate_word_difficulty(w.word, w.locale)::NUMERIC * 100)
    WHERE w.locale = target_locale;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RETURN QUERY SELECT affected_rows;
END;
$$ LANGUAGE plpgsql;

-- Trigger to automatically calculate difficulty on insert/update
CREATE OR REPLACE FUNCTION trigger_calculate_word_difficulty()
RETURNS TRIGGER AS $$
BEGIN
    -- Only recalculate if word or locale changed (or new row)
    IF TG_OP = 'INSERT' OR NEW.word != OLD.word OR NEW.locale != OLD.locale THEN
        NEW.difficulty_value := ROUND(calculate_word_difficulty(NEW.word, NEW.locale)::NUMERIC * 100);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on words table
DROP TRIGGER IF EXISTS calculate_difficulty_on_change ON public.words;
CREATE TRIGGER calculate_difficulty_on_change
    BEFORE INSERT OR UPDATE ON public.words
    FOR EACH ROW
    EXECUTE FUNCTION trigger_calculate_word_difficulty();

-- Add helpful comments
COMMENT ON TABLE public.letter_frequencies IS 'Letter frequency data by language for difficulty calculation';
COMMENT ON FUNCTION calculate_word_difficulty IS 'Calculates word difficulty (0-1) based on unique letters, length, and letter rarity';
COMMENT ON FUNCTION update_all_word_difficulties IS 'Updates difficulty_value for all words in the database';
COMMENT ON FUNCTION update_word_difficulties_by_locale IS 'Updates difficulty_value for words of a specific locale';
COMMENT ON FUNCTION trigger_calculate_word_difficulty IS 'Trigger function to auto-calculate difficulty on insert/update';

