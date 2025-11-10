-- إنشاء جداول نظام الرسائل في Supabase

-- 1. جدول الرسائل
CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'file', 'image', 'audio', 'video')),
  file_url TEXT,
  is_read BOOLEAN DEFAULT false,
  is_deleted_by_sender BOOLEAN DEFAULT false,
  is_deleted_by_receiver BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. جدول المحادثات (للأداء)
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id TEXT NOT NULL,
  user2_id TEXT NOT NULL,
  last_message_id UUID REFERENCES public.messages(id),
  last_message_time TIMESTAMP WITH TIME ZONE,
  user1_unread_count INT DEFAULT 0,
  user2_unread_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);

-- فهارس للأداء
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
CREATE INDEX idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX idx_messages_created_at ON public.messages(created_at DESC);
CREATE INDEX idx_conversations_users ON public.conversations(user1_id, user2_id);

-- تفعيل Realtime للرسائل
ALTER TABLE public.messages REPLICA IDENTITY FULL;
ALTER TABLE public.conversations REPLICA IDENTITY FULL;

-- سياسات الأمان
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

-- سياسات الرسائل
CREATE POLICY "Users can read their messages" ON public.messages
  FOR SELECT USING (
    auth.uid()::text = sender_id OR 
    auth.uid()::text = receiver_id
  );

CREATE POLICY "Users can send messages" ON public.messages
  FOR INSERT WITH CHECK (auth.uid()::text = sender_id);

CREATE POLICY "Users can update their messages" ON public.messages
  FOR UPDATE USING (auth.uid()::text = sender_id);

-- سياسات المحادثات
CREATE POLICY "Users can read their conversations" ON public.conversations
  FOR SELECT USING (
    auth.uid()::text = user1_id OR 
    auth.uid()::text = user2_id
  );

CREATE POLICY "Users can create conversations" ON public.conversations
  FOR INSERT WITH CHECK (
    auth.uid()::text = user1_id OR 
    auth.uid()::text = user2_id
  );

CREATE POLICY "Users can update their conversations" ON public.conversations
  FOR UPDATE USING (
    auth.uid()::text = user1_id OR 
    auth.uid()::text = user2_id
  );

-- Function لتحديث آخر رسالة في المحادثة
CREATE OR REPLACE FUNCTION update_conversation_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE conversations
  SET 
    last_message_id = NEW.id,
    last_message_time = NEW.created_at,
    updated_at = NOW(),
    user1_unread_count = CASE 
      WHEN NEW.sender_id = user1_id THEN user1_unread_count
      ELSE user1_unread_count + 1
    END,
    user2_unread_count = CASE 
      WHEN NEW.sender_id = user2_id THEN user2_unread_count
      ELSE user2_unread_count + 1
    END
  WHERE 
    (user1_id = NEW.sender_id AND user2_id = NEW.receiver_id) OR
    (user1_id = NEW.receiver_id AND user2_id = NEW.sender_id);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger لتحديث المحادثة عند إرسال رسالة جديدة
CREATE TRIGGER update_conversation_on_new_message
AFTER INSERT ON messages
FOR EACH ROW
EXECUTE FUNCTION update_conversation_last_message();
