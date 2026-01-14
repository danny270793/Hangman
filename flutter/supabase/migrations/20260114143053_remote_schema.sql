alter table "public"."letter_frequencies" enable row level security;


  create policy "Enable read access for all authenticated users"
  on "public"."letter_frequencies"
  as permissive
  for select
  to authenticated
using (true);



