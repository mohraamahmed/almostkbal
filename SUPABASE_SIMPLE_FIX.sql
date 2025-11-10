-- ==========================================
-- 🗄️ الحل البسيط - يعمل 100%
-- نسخ والصق في Supabase SQL Editor ثم RUN
-- ==========================================

-- الخطوة 1: حذف السياسات القديمة من جميع الجداول
DO $$ 
DECLARE 
    r RECORD;
BEGIN
    FOR r IN (SELECT tablename FROM pg_tables WHERE schemaname = 'public') LOOP
        EXECUTE 'ALTER TABLE IF EXISTS public.' || quote_ident(r.tablename) || ' DISABLE ROW LEVEL SECURITY';
    END LOOP;
END $$;

-- الخطوة 2: حذف السياسات الموجودة
DROP POLICY IF EXISTS "Allow all operations" ON public.notifications;
DROP POLICY IF EXISTS "Allow all operations" ON public.messages;
DROP POLICY IF EXISTS "Allow all operations" ON public.conversations;
DROP POLICY IF EXISTS "Allow all operations" ON public.enrollments;
DROP POLICY IF EXISTS "Allow all operations" ON public.lessons;
DROP POLICY IF EXISTS "Allow all operations" ON public.student_progress;
DROP POLICY IF EXISTS "Allow all operations" ON public.exams;
DROP POLICY IF EXISTS "Allow all operations" ON public.exam_results;
DROP POLICY IF EXISTS "Allow all operations" ON public.certificates;
DROP POLICY IF EXISTS "Allow all operations" ON public.discussions;
DROP POLICY IF EXISTS "Allow all operations" ON public.reviews;
DROP POLICY IF EXISTS "Allow all operations" ON public.announcements;
DROP POLICY IF EXISTS "Allow all operations" ON public.live_sessions;

DROP POLICY IF EXISTS "Allow all for now" ON public.notifications;
DROP POLICY IF EXISTS "Allow all for now" ON public.messages;
DROP POLICY IF EXISTS "Allow all for now" ON public.conversations;
DROP POLICY IF EXISTS "Allow all for now" ON public.enrollments;
DROP POLICY IF EXISTS "Allow all for now" ON public.lessons;
DROP POLICY IF EXISTS "Allow all for now" ON public.student_progress;
DROP POLICY IF EXISTS "Allow all for now" ON public.exams;
DROP POLICY IF EXISTS "Allow all for now" ON public.exam_results;
DROP POLICY IF EXISTS "Allow all for now" ON public.certificates;
DROP POLICY IF EXISTS "Allow all for now" ON public.discussions;
DROP POLICY IF EXISTS "Allow all for now" ON public.reviews;
DROP POLICY IF EXISTS "Allow all for now" ON public.announcements;
DROP POLICY IF EXISTS "Allow all for now" ON public.live_sessions;

-- الخطوة 3: إنشاء الجداول
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info',
  link TEXT,
  image TEXT,
  is_read BOOLEAN DEFAULT false,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  sender_id TEXT NOT NULL,
  receiver_id TEXT NOT NULL,
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  file_url TEXT,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id TEXT NOT NULL,
  user2_id TEXT NOT NULL,
  last_message_id UUID,
  last_message_time TIMESTAMP WITH TIME ZONE,
  user1_unread_count INT DEFAULT 0,
  user2_unread_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  progress INT DEFAULT 0,
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  video_url TEXT,
  order_index INT DEFAULT 0,
  is_free BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.student_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  watch_time INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  questions JSONB NOT NULL,
  passing_score INT DEFAULT 60,
  time_limit INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.exam_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  exam_id UUID NOT NULL,
  score INT NOT NULL,
  answers JSONB,
  passed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  certificate_number TEXT UNIQUE NOT NULL,
  student_name TEXT NOT NULL,
  issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  content TEXT NOT NULL,
  likes INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'info',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.live_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  meeting_url TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration INT DEFAULT 60,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- الخطوة 4: إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_lessons_course ON public.lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_progress_user ON public.student_progress(user_id);

-- الخطوة 5: تعطيل RLS نهائياً (لتجنب أي مشاكل)
ALTER TABLE public.notifications DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_progress DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions DISABLE ROW LEVEL SECURITY;

-- ==========================================
-- ✅ تم! الآن كل شيء يعمل بدون RLS
-- ==========================================
