-- ================================================================
-- Supabase Storage — case-photos bucket setup
-- Run AFTER creating the bucket in Dashboard → Storage → New bucket
-- Bucket settings: name=case-photos, Public=true
-- ================================================================

-- Allow anyone to view photos (public bucket)
create policy "Public read case photos"
  on storage.objects for select
  using (bucket_id = 'case-photos');

-- Allow authenticated users to upload
create policy "Authenticated upload case photos"
  on storage.objects for insert
  with check (
    bucket_id = 'case-photos'
    and auth.role() = 'authenticated'
  );

-- Allow users to delete their own uploads
create policy "Users delete own photos"
  on storage.objects for delete
  using (
    bucket_id = 'case-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
