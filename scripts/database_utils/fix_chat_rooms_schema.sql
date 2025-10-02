-- Quick fix for messaging system: Add missing columns to chat_rooms table
-- This will resolve the "column chat_rooms.user1_id does not exist" error

-- Add missing columns for direct messaging
ALTER TABLE chat_rooms 
ADD COLUMN IF NOT EXISTS user1_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS user2_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
ADD COLUMN IF NOT EXISTS room_type VARCHAR(20) DEFAULT 'group',
ADD COLUMN IF NOT EXISTS last_message_at TIMESTAMPTZ DEFAULT NOW();

-- Create index for better performance on direct message queries
CREATE INDEX IF NOT EXISTS idx_chat_rooms_direct_messages 
ON chat_rooms(user1_id, user2_id) 
WHERE room_type = 'direct';

-- Create index for user-based lookups
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user1 ON chat_rooms(user1_id);
CREATE INDEX IF NOT EXISTS idx_chat_rooms_user2 ON chat_rooms(user2_id);

-- Update existing rooms to have proper room_type
UPDATE chat_rooms 
SET room_type = 'group' 
WHERE room_type IS NULL;

COMMENT ON COLUMN chat_rooms.user1_id IS 'First user in direct message (null for group chats)';
COMMENT ON COLUMN chat_rooms.user2_id IS 'Second user in direct message (null for group chats)';
COMMENT ON COLUMN chat_rooms.room_type IS 'Type of chat room: direct, group, announcement';
COMMENT ON COLUMN chat_rooms.last_message_at IS 'Timestamp of last message for sorting';