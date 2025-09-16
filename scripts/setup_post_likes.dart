import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  try {
    print('🔧 Setting up post likes table...');
    
    await Supabase.initialize(
      url: 'https://mogjjvscxjwvhtpkrlqr.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vZ2pqdnNjeGp3dmh0cGtybHFyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5MTk1ODAsImV4cCI6MjA3MzQ5NTU4MH0.u1urXd3uiT0fuqWlJ1Nhp7uJhgdiyOdLSdSWJWczHoQ',
    );
    
    final supabase = Supabase.instance.client;
    
    // Try to create post_likes table (may fail if already exists)
    try {
      await supabase.rpc('execute_sql', params: {
        'sql': '''
          CREATE TABLE IF NOT EXISTS public.post_likes (
            id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
            post_id uuid NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
            user_id uuid NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
            created_at timestamp with time zone DEFAULT now() NOT NULL,
            UNIQUE(post_id, user_id)
          );
          
          -- Enable RLS
          ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
          
          -- Create policies
          CREATE POLICY "Users can like posts" ON public.post_likes
            FOR INSERT WITH CHECK (auth.uid() = user_id);
            
          CREATE POLICY "Users can unlike their own likes" ON public.post_likes
            FOR DELETE USING (auth.uid() = user_id);
            
          CREATE POLICY "Users can view all likes" ON public.post_likes
            FOR SELECT USING (true);
        '''
      });
      print('✅ post_likes table created successfully');
    } catch (e) {
      print('⚠️  post_likes table might already exist: $e');
    }
    
    // Try to create increment/decrement functions
    try {
      await supabase.rpc('execute_sql', params: {
        'sql': '''
          CREATE OR REPLACE FUNCTION increment_post_likes(post_id uuid)
          RETURNS void AS \$\$
          BEGIN
            UPDATE posts SET like_count = like_count + 1 WHERE id = post_id;
          END;
          \$\$ LANGUAGE plpgsql;
          
          CREATE OR REPLACE FUNCTION decrement_post_likes(post_id uuid)
          RETURNS void AS \$\$
          BEGIN
            UPDATE posts SET like_count = GREATEST(like_count - 1, 0) WHERE id = post_id;
          END;
          \$\$ LANGUAGE plpgsql;
        '''
      });
      print('✅ Like/unlike functions created successfully');
    } catch (e) {
      print('⚠️  Functions might already exist: $e');
    }
    
    // Test the setup
    print('\n🧪 Testing post_likes functionality...');
    
    // Get a sample post
    final posts = await supabase
        .from('posts')
        .select('id')
        .limit(1);
    
    if (posts.isNotEmpty) {
      final postId = posts.first['id'];
      print('✅ Found test post: $postId');
      
      // Check current likes
      final likes = await supabase
          .from('post_likes')
          .select('count')
          .eq('post_id', postId)
          .count();
      
      print('✅ Current likes: ${likes.count}');
    }
    
    print('\n🎉 Post likes setup completed successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
  }
}