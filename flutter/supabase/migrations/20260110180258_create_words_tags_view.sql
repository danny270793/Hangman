-- Create a view to fetch words with their tags in a single query
CREATE OR REPLACE VIEW public.words_with_tags AS
SELECT 
    w.id,
    w.word,
    w.difficulty_value,
    w.locale,
    w.created_at,
    COALESCE(
        ARRAY_AGG(t.tag ORDER BY t.tag) FILTER (WHERE t.tag IS NOT NULL),
        ARRAY[]::TEXT[]
    ) as tags
FROM public.words w
LEFT JOIN public.word_tags wt ON w.id = wt.word_id
LEFT JOIN public.tags t ON wt.tag_id = t.id
GROUP BY w.id, w.word, w.difficulty_value, w.locale, w.created_at;

-- Grant SELECT permission on the view to authenticated users
GRANT SELECT ON public.words_with_tags TO authenticated;

COMMENT ON VIEW public.words_with_tags IS 'View that returns words with their associated tags as an array for efficient querying';
