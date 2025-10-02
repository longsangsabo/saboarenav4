-- Simple SQL script to fix chat_rooms table
-- Execute this directly in Supabase SQL editor

-- Add missing columns for messaging system
ALTER TABLE chat_rooms 
ADD COLUMN IF NOT EXISTS user1_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS user2_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS room_type VARCHAR(20) DEFAULT 'group',
ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ DEFAULT NOW();

-- Create indexes for performance  
CREATE INDEX IF NOT EXISTS idx_chat_rooms_direct_messages 
ON chat_rooms(user1_id, user2_id) 
WHERE room_type = 'direct';

CREATE INDEX IF NOT EXISTS idx_chat_rooms_user1 ON chat_rooms(user1_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user2 ON chat_rooms(user2_id);

-- Update existing room types
UPDATE chat_rooms SET room_type = 'group' WHERE room_type IS NULL;