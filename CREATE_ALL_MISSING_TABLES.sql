-- ==========================================
-- إنشاء كل الجداول المفقودة في Supabase
-- ==========================================

-- 1. جدول التسجيلات (Enrollments)
CREATE TABLE IF NOT EXISTS public.enrollments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id UUID NOT NULL,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'completed', 'cancelled')),
  progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  enrolled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  payment_status TEXT DEFAULT 'pending',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. جدول الدروس (Lessons)
CREATE TABLE IF NOT EXISTS public.lessons (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  content TEXT,
  video_url TEXT,
  duration INT, -- بالدقائق
  order_index INT NOT NULL,
  is_free BOOLEAN DEFAULT false,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. جدول تقدم الطلاب (Progress)
CREATE TABLE IF NOT EXISTS public.student_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id UUID NOT NULL,
  lesson_id UUID NOT NULL,
  is_completed BOOLEAN DEFAULT false,
  watch_time INT DEFAULT 0, -- بالثواني
  completed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, lesson_id)
);

-- 4. جدول الامتحانات (Exams)
CREATE TABLE IF NOT EXISTS public.exams (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  questions JSONB NOT NULL,
  passing_score INT DEFAULT 60,
  time_limit INT, -- بالدقائق
  attempts_allowed INT DEFAULT 3,
  is_published BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. جدول نتائج الامتحانات
CREATE TABLE IF NOT EXISTS public.exam_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  exam_id UUID NOT NULL,
  score INT NOT NULL,
  answers JSONB,
  attempt_number INT DEFAULT 1,
  time_taken INT, -- بالثواني
  passed BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. جدول الشهادات
CREATE TABLE IF NOT EXISTS public.certificates (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id UUID NOT NULL,
  certificate_number TEXT UNIQUE NOT NULL,
  issue_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  grade TEXT,
  pdf_url TEXT,
  is_verified BOOLEAN DEFAULT true
);

-- 7. جدول التعليقات والمناقشات
CREATE TABLE IF NOT EXISTS public.discussions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL,
  lesson_id UUID,
  user_id TEXT NOT NULL,
  parent_id UUID, -- للردود
  content TEXT NOT NULL,
  is_pinned BOOLEAN DEFAULT false,
  likes INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. جدول التقييمات
CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL,
  user_id TEXT NOT NULL,
  rating INT CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_verified BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(course_id, user_id)
);

-- 9. جدول الإعلانات
CREATE TABLE IF NOT EXISTS public.announcements (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'warning', 'success', 'urgent')),
  target_audience TEXT DEFAULT 'all' CHECK (target_audience IN ('all', 'students', 'teachers', 'admins')),
  is_active BOOLEAN DEFAULT true,
  created_by TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE
);

-- 10. جدول الجلسات المباشرة
CREATE TABLE IF NOT EXISTS public.live_sessions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  meeting_url TEXT,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration INT DEFAULT 60, -- بالدقائق
  max_attendees INT,
  is_recorded BOOLEAN DEFAULT false,
  recording_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إضافة الفهارس للأداء
CREATE INDEX idx_enrollments_user ON public.enrollments(user_id);
CREATE INDEX idx_enrollments_course ON public.enrollments(course_id);
CREATE INDEX idx_lessons_course ON public.lessons(course_id);
CREATE INDEX idx_progress_user ON public.student_progress(user_id);
CREATE INDEX idx_discussions_course ON public.discussions(course_id);
CREATE INDEX idx_reviews_course ON public.reviews(course_id);

-- تفعيل RLS على كل الجداول
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

-- سياسات أمان بسيطة (يمكن تعديلها لاحقاً)
CREATE POLICY "Allow all for now" ON public.enrollments FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.lessons FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.student_progress FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.exams FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.exam_results FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.certificates FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.discussions FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.reviews FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.announcements FOR ALL USING (true);
CREATE POLICY "Allow all for now" ON public.live_sessions FOR ALL USING (true);

-- رسالة نجاح
-- ✅ تم إنشاء كل الجداول المفقودة بنجاح!
