-- SQL để tạo Storage policies cho bucket user-images
-- Chạy trong Supabase Dashboard > SQL Editor

-- 1. Allow anon users to upload to user-images bucket
CREATE POLICY "Allow public uploads" ON storage.objects 
FOR INSERT 
TO anon, authenticated
WITH CHECK (bucket_id = 'user-images');

-- 2. Allow anon users to read from user-images bucket
CREATE POLICY "Allow public reads" ON storage.objects 
FOR SELECT 
TO anon, authenticated
USING (bucket_id = 'user-images');

-- 3. Allow anon users to update objects in user-images bucket (for overwrite)
CREATE POLICY "Allow public updates" ON storage.objects 
FOR UPDATE 
TO anon, authenticated
USING (bucket_id = 'user-images');

-- 4. Optional: Allow anon users to delete from user-images bucket
CREATE POLICY "Allow public deletes" ON storage.objects 
FOR DELETE 
TO anon, authenticated  
USING (bucket_id = 'user-images');

-- Verify policies created
SELECT * FROM pg_policies WHERE tablename = 'objects' AND schemaname = 'storage';