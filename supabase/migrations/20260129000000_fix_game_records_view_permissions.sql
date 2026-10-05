-- Fix permissions for game_records_with_usernames view
-- Change from security_invoker to security_definer so it runs with owner's permissions

-- Drop the existing view
DROP VIEW IF EXISTS public.game_records_with_usernames;

-- Recreate the view with security_definer (runs with owner/postgres permissions)
CREATE OR REPLACE VIEW public.game_records_with_usernames 
WITH (security_invoker='off') AS
SELECT 
    gr.id,
    gr.user_id,
    gr.created_at,
    gr.has_timed_mode_enabled,
    gr.difficulty,
    gr.points,
    gr.words,
    gr.time_playing,
    COALESCE((au.raw_user_meta_data ->> 'username'), 'Player') AS username
FROM public.game_records gr
LEFT JOIN auth.users au ON gr.user_id = au.id;

-- Set owner to postgres
ALTER VIEW public.game_records_with_usernames OWNER TO postgres;

-- Grant SELECT permission to authenticated users
GRANT SELECT ON public.game_records_with_usernames TO authenticated;
GRANT SELECT ON public.game_records_with_usernames TO anon;

-- Add comment explaining the security model
COMMENT ON VIEW public.game_records_with_usernames IS 
'View that joins game_records with auth.users to display usernames. Uses security_definer to allow authenticated users to read usernames without direct access to auth.users table.';
