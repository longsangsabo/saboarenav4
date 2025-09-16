-- Fix comment count trigger functions
-- The issue is that the functions are trying to update 'comments_count' 
-- but the posts table has 'comment_count' (singular)

-- Drop existing triggers and functions first
DROP TRIGGER IF EXISTS trigger_update_comment_count ON post_comments;
DROP FUNCTION IF EXISTS update_post_comment_count();
DROP FUNCTION IF EXISTS increment_post_comments(UUID);
DROP FUNCTION IF EXISTS decrement_post_comments(UUID);

-- Create corrected functions with proper column name
CREATE OR REPLACE FUNCTION increment_post_comments(post_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE posts SET comment_count = COALESCE(comment_count, 0) + 1 WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION decrement_post_comments(post_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE posts SET comment_count = GREATEST(COALESCE(comment_count, 0) - 1, 0) WHERE id = post_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger function to update comment count automatically
CREATE OR REPLACE FUNCTION update_post_comment_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        PERFORM increment_post_comments(NEW.post_id);
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        PERFORM decrement_post_comments(OLD.post_id);
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create the trigger
CREATE TRIGGER trigger_update_comment_count
    AFTER INSERT OR DELETE ON post_comments
    FOR EACH ROW EXECUTE FUNCTION update_post_comment_count();

-- Test the fix
DO $$
DECLARE
    test_user_id UUID;
    test_post_id UUID;
    test_comment_id UUID;
BEGIN
    -- Get first user and post
    SELECT id INTO test_user_id FROM users LIMIT 1;
    SELECT id INTO test_post_id FROM posts LIMIT 1;
    
    IF test_user_id IS NOT NULL AND test_post_id IS NOT NULL THEN
        -- Try to insert a test comment
        INSERT INTO post_comments (user_id, post_id, content)
        VALUES (test_user_id, test_post_id, 'Test comment - trigger fix')
        RETURNING id INTO test_comment_id;
        
        RAISE NOTICE 'Test comment created with ID: %', test_comment_id;
        
        -- Check if comment count was updated
        PERFORM 1 FROM posts WHERE id = test_post_id AND comment_count > 0;
        
        IF FOUND THEN
            RAISE NOTICE 'SUCCESS: Comment count trigger is working!';
        ELSE
            RAISE NOTICE 'ERROR: Comment count was not updated';
        END IF;
        
    ELSE
        RAISE NOTICE 'ERROR: No users or posts found for testing';
    END IF;
END $$;