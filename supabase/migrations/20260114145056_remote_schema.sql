


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";






CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."difficulty" AS ENUM (
    'easy',
    'medium',
    'hard'
);


ALTER TYPE "public"."difficulty" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text" DEFAULT 'en'::"text") RETURNS numeric
    LANGUAGE "plpgsql" IMMUTABLE
    AS $$
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
$$;


ALTER FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text") IS 'Calculates word difficulty (0-1) based on unique letters, length, and letter rarity';



CREATE OR REPLACE FUNCTION "public"."trigger_calculate_word_difficulty"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    -- Only recalculate if word or locale changed (or new row)
    IF TG_OP = 'INSERT' OR NEW.word != OLD.word OR NEW.locale != OLD.locale THEN
        NEW.difficulty_value := ROUND(calculate_word_difficulty(NEW.word, NEW.locale)::NUMERIC * 100);
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."trigger_calculate_word_difficulty"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."trigger_calculate_word_difficulty"() IS 'Trigger function to auto-calculate difficulty on insert/update';



CREATE OR REPLACE FUNCTION "public"."update_all_word_difficulties"() RETURNS TABLE("updated_count" integer)
    LANGUAGE "plpgsql"
    AS $$
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
$$;


ALTER FUNCTION "public"."update_all_word_difficulties"() OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_all_word_difficulties"() IS 'Updates difficulty_value for all words in the database';



CREATE OR REPLACE FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") RETURNS TABLE("updated_count" integer)
    LANGUAGE "plpgsql"
    AS $$
DECLARE
    affected_rows INT := 0;
BEGIN
    UPDATE public.words w
    SET difficulty_value = ROUND(calculate_word_difficulty(w.word, w.locale)::NUMERIC * 100)
    WHERE w.locale = target_locale;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    
    RETURN QUERY SELECT affected_rows;
END;
$$;


ALTER FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") OWNER TO "postgres";


COMMENT ON FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") IS 'Updates difficulty_value for words of a specific locale';


SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."game_records" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "user_id" "uuid" DEFAULT "auth"."uid"() NOT NULL,
    "has_timed_mode_enabled" boolean,
    "difficulty" "public"."difficulty",
    "points" bigint,
    "words" bigint,
    "time_playing" bigint
);


ALTER TABLE "public"."game_records" OWNER TO "postgres";


CREATE OR REPLACE VIEW "public"."game_records_with_usernames" WITH ("security_invoker"='on') AS
 SELECT "gr"."id",
    "gr"."user_id",
    "gr"."created_at",
    "gr"."has_timed_mode_enabled",
    "gr"."difficulty",
    "gr"."points",
    "gr"."words",
    "gr"."time_playing",
    COALESCE(("au"."raw_user_meta_data" ->> 'username'::"text"), 'Player'::"text") AS "username"
   FROM ("public"."game_records" "gr"
     LEFT JOIN "auth"."users" "au" ON (("gr"."user_id" = "au"."id")));


ALTER VIEW "public"."game_records_with_usernames" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."letter_frequencies" (
    "letter" character(1) NOT NULL,
    "locale" "text" NOT NULL,
    "frequency" numeric(3,2) NOT NULL,
    CONSTRAINT "letter_frequencies_frequency_check" CHECK ((("frequency" >= (0)::numeric) AND ("frequency" <= (1)::numeric)))
);


ALTER TABLE "public"."letter_frequencies" OWNER TO "postgres";


COMMENT ON TABLE "public"."letter_frequencies" IS 'Letter frequency data by language for difficulty calculation';



ALTER TABLE "public"."game_records" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."records_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."tags" (
    "id" bigint NOT NULL,
    "tag" "text" NOT NULL,
    "locale" "text" DEFAULT 'en'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."tags" IS 'Stores descriptive tags/hints for words';



ALTER TABLE "public"."tags" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."tags_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE TABLE IF NOT EXISTS "public"."word_tags" (
    "word_id" bigint NOT NULL,
    "tag_id" bigint NOT NULL
);


ALTER TABLE "public"."word_tags" OWNER TO "postgres";


COMMENT ON TABLE "public"."word_tags" IS 'Junction table linking words to their tags';



CREATE TABLE IF NOT EXISTS "public"."words" (
    "id" bigint NOT NULL,
    "word" "text" NOT NULL,
    "difficulty_value" integer NOT NULL,
    "locale" "text" DEFAULT 'en'::"text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "words_difficulty_value_check" CHECK ((("difficulty_value" >= 1) AND ("difficulty_value" <= 100)))
);


ALTER TABLE "public"."words" OWNER TO "postgres";


COMMENT ON TABLE "public"."words" IS 'Stores words for the Hangman game with difficulty values and locale';



ALTER TABLE "public"."words" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."words_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);



CREATE OR REPLACE VIEW "public"."words_with_tags" WITH ("security_invoker"='on') AS
 SELECT "w"."id",
    "w"."word",
    "w"."difficulty_value",
    "w"."locale",
    "w"."created_at",
    COALESCE("array_agg"("t"."tag" ORDER BY "t"."tag") FILTER (WHERE ("t"."tag" IS NOT NULL)), ARRAY[]::"text"[]) AS "tags"
   FROM (("public"."words" "w"
     LEFT JOIN "public"."word_tags" "wt" ON (("w"."id" = "wt"."word_id")))
     LEFT JOIN "public"."tags" "t" ON (("wt"."tag_id" = "t"."id")))
  GROUP BY "w"."id", "w"."word", "w"."difficulty_value", "w"."locale", "w"."created_at";


ALTER VIEW "public"."words_with_tags" OWNER TO "postgres";


COMMENT ON VIEW "public"."words_with_tags" IS 'View that returns words with their associated tags as an array for efficient querying';



ALTER TABLE ONLY "public"."letter_frequencies"
    ADD CONSTRAINT "letter_frequencies_pkey" PRIMARY KEY ("letter", "locale");



ALTER TABLE ONLY "public"."game_records"
    ADD CONSTRAINT "records_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."tags"
    ADD CONSTRAINT "tags_tag_locale_unique" UNIQUE ("tag", "locale");



ALTER TABLE ONLY "public"."word_tags"
    ADD CONSTRAINT "word_tags_pkey" PRIMARY KEY ("word_id", "tag_id");



ALTER TABLE ONLY "public"."words"
    ADD CONSTRAINT "words_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."words"
    ADD CONSTRAINT "words_word_locale_unique" UNIQUE ("word", "locale");



CREATE INDEX "idx_game_records_created_at" ON "public"."game_records" USING "btree" ("created_at" DESC);



CREATE INDEX "idx_game_records_difficulty_points" ON "public"."game_records" USING "btree" ("difficulty", "points" DESC);



CREATE INDEX "idx_game_records_points" ON "public"."game_records" USING "btree" ("points" DESC);



CREATE INDEX "idx_game_records_user_id" ON "public"."game_records" USING "btree" ("user_id");



CREATE INDEX "idx_tags_locale" ON "public"."tags" USING "btree" ("locale");



CREATE INDEX "idx_word_tags_tag_id" ON "public"."word_tags" USING "btree" ("tag_id");



CREATE INDEX "idx_word_tags_word_id" ON "public"."word_tags" USING "btree" ("word_id");



CREATE INDEX "idx_words_difficulty" ON "public"."words" USING "btree" ("difficulty_value");



CREATE INDEX "idx_words_locale" ON "public"."words" USING "btree" ("locale");



CREATE INDEX "idx_words_locale_difficulty" ON "public"."words" USING "btree" ("locale", "difficulty_value");



CREATE OR REPLACE TRIGGER "calculate_difficulty_on_change" BEFORE INSERT OR UPDATE ON "public"."words" FOR EACH ROW EXECUTE FUNCTION "public"."trigger_calculate_word_difficulty"();



ALTER TABLE ONLY "public"."game_records"
    ADD CONSTRAINT "records_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."word_tags"
    ADD CONSTRAINT "word_tags_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."tags"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."word_tags"
    ADD CONSTRAINT "word_tags_word_id_fkey" FOREIGN KEY ("word_id") REFERENCES "public"."words"("id") ON DELETE CASCADE;



CREATE POLICY "Anyone authenticated can view tags" ON "public"."tags" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Anyone authenticated can view word_tags" ON "public"."word_tags" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Anyone authenticated can view words" ON "public"."words" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Anyone can view game records" ON "public"."game_records" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Enable read access for all authenticated users" ON "public"."letter_frequencies" FOR SELECT TO "authenticated" USING (true);



CREATE POLICY "Users can insert their own game records" ON "public"."game_records" FOR INSERT TO "authenticated" WITH CHECK (("auth"."uid"() = "user_id"));



ALTER TABLE "public"."game_records" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."letter_frequencies" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."word_tags" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."words" ENABLE ROW LEVEL SECURITY;




ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";

























































































































































GRANT ALL ON FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_word_difficulty"("word_text" "text", "word_locale" "text") TO "service_role";



GRANT ALL ON FUNCTION "public"."trigger_calculate_word_difficulty"() TO "anon";
GRANT ALL ON FUNCTION "public"."trigger_calculate_word_difficulty"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."trigger_calculate_word_difficulty"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_all_word_difficulties"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_all_word_difficulties"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_all_word_difficulties"() TO "service_role";



GRANT ALL ON FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_word_difficulties_by_locale"("target_locale" "text") TO "service_role";


















GRANT ALL ON TABLE "public"."game_records" TO "anon";
GRANT ALL ON TABLE "public"."game_records" TO "authenticated";
GRANT ALL ON TABLE "public"."game_records" TO "service_role";



GRANT ALL ON TABLE "public"."game_records_with_usernames" TO "anon";
GRANT ALL ON TABLE "public"."game_records_with_usernames" TO "authenticated";
GRANT ALL ON TABLE "public"."game_records_with_usernames" TO "service_role";



GRANT ALL ON TABLE "public"."letter_frequencies" TO "anon";
GRANT ALL ON TABLE "public"."letter_frequencies" TO "authenticated";
GRANT ALL ON TABLE "public"."letter_frequencies" TO "service_role";



GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."records_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."tags" TO "anon";
GRANT ALL ON TABLE "public"."tags" TO "authenticated";
GRANT ALL ON TABLE "public"."tags" TO "service_role";



GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."tags_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."word_tags" TO "anon";
GRANT ALL ON TABLE "public"."word_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."word_tags" TO "service_role";



GRANT ALL ON TABLE "public"."words" TO "anon";
GRANT ALL ON TABLE "public"."words" TO "authenticated";
GRANT ALL ON TABLE "public"."words" TO "service_role";



GRANT ALL ON SEQUENCE "public"."words_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."words_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."words_id_seq" TO "service_role";



GRANT ALL ON TABLE "public"."words_with_tags" TO "anon";
GRANT ALL ON TABLE "public"."words_with_tags" TO "authenticated";
GRANT ALL ON TABLE "public"."words_with_tags" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































drop extension if exists "pg_net";


