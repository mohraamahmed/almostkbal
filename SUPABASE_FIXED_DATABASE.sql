-- ==========================================
-- 🗄️ قاعدة البيانات الكاملة - النسخة المُصلحة
-- متوافقة مع localStorage و Supabase Auth
-- نسخ والصق كاملاً في Supabase SQL Editor ثم RUN
-- ==========================================

-- 1️⃣ جدول الإشعارات (Notifications)
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL, -- TEXT لأننا نستخدم phone من localStorage
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error', 'course', 'certificate', 'payment', 'announcement')),
  link TEXT,
  image TEXT,
  is_read BOOLEAN DEFAULT false,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON public.notifications(created_at DESC);

-- 2️⃣ جدول الرسائل (Messages)
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

CREATE INDEX IF NOT EXISTS idx_messages_sender ON public.messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_receiver ON public.messages(receiver_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON public.messages(created_at DESC);

-- 3️⃣ جدول المحادثات (Conversations)
CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user1_id TEXT NOT NULL,
  user2_id TEXT NOT NULL,
  last_message_id UUID,
  last_message_time TIMESTAMP WITH TIME ZONE,
  user1_unread_count INT DEFAULT 0,
  user2_unread_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user1_id, user2_id)
);

CREATE INDEX IF NOT EXISTS idx_conversations_users ON public.conversations(user1_id, user2_id);

-- 4️⃣ جدول الاشتراكات (Enrollments)
CREATE TABLE IF NOT EXISTS public.enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL, -- phone number من localStorage
  course_id TEXT NOT NULL, -- course ID
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed', 'cancelled', 'expired')),
  progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  expires_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  payment_status TEXT DEFAULT 'pending' CHECK (payment_status IN ('pending', 'paid', 'refunded')),
  payment_amount DECIMAL(10,2),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_course ON public.enrollments(course_id);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON public.enrollments(status);

-- 5️⃣ جدول الدروس (Lessons)
CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  content TEXT,
  video_url TEXT,
  video_duration INT, -- بالثواني
  order_index INT NOT NULL DEFAULT 0,
  is_free BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  resources JSONB, -- ملفات مرفقة
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_lessons_course ON public.lessons(course_id);
CREATE INDEX IF NOT EXISTS idx_lessons_order ON public.lessons(course_id, order_index);

-- 6️⃣ جدول تقدم الطلاب (Student Progress)
CREATE TABLE IF NOT EXISTS public.student_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  watch_time INT DEFAULT 0, -- بالثواني
  last_position INT DEFAULT 0, -- آخر موضع في الفيديو
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

CREATE INDEX IF NOT EXISTS idx_progress_user ON public.student_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_course ON public.student_progress(course_id);
CREATE INDEX IF NOT EXISTS idx_progress_lesson ON public.student_progress(lesson_id);

-- 7️⃣ جدول الامتحانات (Exams)
CREATE TABLE IF NOT EXISTS public.exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  instructions TEXT,
  questions JSONB NOT NULL, -- array of questions
  passing_score INT DEFAULT 60 CHECK (passing_score >= 0 AND passing_score <= 100),
  time_limit INT, -- بالدقائق
  attempts_allowed INT DEFAULT 3,
  shuffle_questions BOOLEAN DEFAULT false,
  show_results_immediately BOOLEAN DEFAULT true,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exams_course ON public.exams(course_id);

-- 8️⃣ جدول نتائج الامتحانات (Exam Results)
CREATE TABLE IF NOT EXISTS public.exam_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  exam_id UUID NOT NULL,
  score INT NOT NULL CHECK (score >= 0 AND score <= 100),
  answers JSONB, -- إجابات الطالب
  correct_answers INT DEFAULT 0,
  total_questions INT DEFAULT 0,
  attempt_number INT DEFAULT 1,
  time_taken INT, -- بالثواني
  passed BOOLEAN DEFAULT false,
  feedback TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_exam_results_user ON public.exam_results(user_id);
CREATE INDEX IF NOT EXISTS idx_exam_results_exam ON public.exam_results(exam_id);

-- 9️⃣ جدول الشهادات (Certificates)
CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  certificate_number TEXT UNIQUE NOT NULL,
  student_name TEXT NOT NULL,
  course_name TEXT NOT NULL,
  issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completion_date TIMESTAMP WITH TIME ZONE,
  grade TEXT, -- ممتاز، جيد جداً، جيد
  score INT, -- النتيجة النهائية
  certificate_url TEXT, -- رابط ملف PDF
  verification_url TEXT, -- رابط التحقق
  is_verified BOOLEAN DEFAULT true,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_certificates_user ON public.certificates(user_id);
CREATE INDEX IF NOT EXISTS idx_certificates_course ON public.certificates(course_id);
CREATE INDEX IF NOT EXISTS idx_certificates_number ON public.certificates(certificate_number);

-- 🔟 جدول المناقشات (Discussions)
CREATE TABLE IF NOT EXISTS public.discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  lesson_id TEXT,
  user_id TEXT NOT NULL,
  parent_id UUID, -- للردود
  content TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT false,
  is_answered BOOLEAN DEFAULT false,
  likes INT DEFAULT 0,
  replies_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_discussions_course ON public.discussions(course_id);
CREATE INDEX IF NOT EXISTS idx_discussions_lesson ON public.discussions(lesson_id);
CREATE INDEX IF NOT EXISTS idx_discussions_user ON public.discussions(user_id);
CREATE INDEX IF NOT EXISTS idx_discussions_parent ON public.discussions(parent_id);

-- 1️⃣1️⃣ جدول التقييمات (Reviews)
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  user_id TEXT NOT NULL,
  rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_verified BOOLEAN DEFAULT false,
  is_visible BOOLEAN DEFAULT true,
  helpful_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_reviews_course ON public.reviews(course_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user ON public.reviews(user_id);
CREATE INDEX IF NOT EXISTS idx_reviews_rating ON public.reviews(rating);

-- 1️⃣2️⃣ جدول الإعلانات (Announcements)
CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'warning', 'success', 'urgent', 'maintenance')),
  target_audience TEXT DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'teachers', 'admins')),
  course_id TEXT, -- null = للجميع
  is_active BOOLEAN DEFAULT true,
  is_dismissible BOOLEAN DEFAULT true,
  priority INT DEFAULT 0, -- أعلى رقم = أعلى أولوية
  icon TEXT,
  action_url TEXT,
  action_text TEXT,
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX IF NOT EXISTS idx_announcements_active ON public.announcements(is_active);
CREATE INDEX IF NOT EXISTS idx_announcements_audience ON public.announcements(target_audience);

-- 1️⃣3️⃣ جدول الجلسات المباشرة (Live Sessions)
CREATE TABLE IF NOT EXISTS public.live_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  instructor_name TEXT,
  meeting_url TEXT NOT NULL,
  meeting_password TEXT,
  platform TEXT DEFAULT 'zoom' CHECK (platform IN ('zoom', 'google-meet', 'teams', 'custom')),
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE,
  duration INT DEFAULT 60, -- بالدقائق
  max_attendees INT,
  current_attendees INT DEFAULT 0,
  is_recorded BOOLEAN DEFAULT false,
  recording_url TEXT,
  is_active BOOLEAN DEFAULT true,
  reminder_sent BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_live_sessions_course ON public.live_sessions(course_id);
CREATE INDEX IF NOT EXISTS idx_live_sessions_time ON public.live_sessions(start_time);

-- ==========================================
-- 🔒 سياسات الأمان (RLS)
-- ==========================================

-- تفعيل RLS على كل الجداول
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lessons ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.student_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exam_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.certificates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.discussions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.live_sessions ENABLE ROW LEVEL SECURITY;

-- حذف السياسات القديمة إن وجدت
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

-- سياسات مبسطة للبداية (السماح بكل العمليات)
CREATE POLICY "Allow all for now" ON public.notifications FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.conversations FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.enrollments FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.lessons FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.student_progress FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.exams FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.exam_results FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.certificates FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.discussions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.reviews FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.announcements FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for now" ON public.live_sessions FOR ALL USING (true) WITH CHECK (true);

-- ==========================================
-- ✅ تم إنشاء كل الجداول بنجاح!
-- ==========================================

-- الخطوة التالية:
-- Database → Replication → Enable للجداول:
-- ☑️ notifications
-- ☑️ messages
-- ☑️ conversations
-- ☑️ announcements
