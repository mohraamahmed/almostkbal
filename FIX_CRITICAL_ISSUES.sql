-- ==========================================
-- 🔧 إصلاح المشاكل الحرجة
-- شغل هذا في Supabase SQL Editor
-- ==========================================

-- 1️⃣ إصلاح جدول conversations
-- إضافة الأعمدة الناقصة
ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS last_message_id UUID;

ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- إضافة UNIQUE constraint
ALTER TABLE public.conversations 
DROP CONSTRAINT IF EXISTS unique_users;

ALTER TABLE public.conversations 
ADD CONSTRAINT unique_users UNIQUE (user1_id, user2_id);

-- 2️⃣ إصلاح جدول certificates
-- إضافة UNIQUE constraint لرقم الشهادة
ALTER TABLE public.certificates 
DROP CONSTRAINT IF EXISTS unique_certificate_number;

ALTER TABLE public.certificates 
ADD CONSTRAINT unique_certificate_number UNIQUE (certificate_number);

-- 3️⃣ إضافة حقول إضافية مفيدة

-- في student_progress: إضافة last_watched
ALTER TABLE public.student_progress 
ADD COLUMN IF NOT EXISTS last_watched TIMESTAMP WITH TIME ZONE;

-- في enrollments: إضافة completed_at و expires_at
ALTER TABLE public.enrollments 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

-- في discussions: إضافة parent_id للردود
ALTER TABLE public.discussions 
ADD COLUMN IF NOT EXISTS parent_id UUID REFERENCES public.discussions(id);

-- في reviews: إضافة UNIQUE constraint
ALTER TABLE public.reviews 
DROP CONSTRAINT IF EXISTS unique_course_user_review;

ALTER TABLE public.reviews 
ADD CONSTRAINT unique_course_user_review UNIQUE (course_id, user_id);

-- 4️⃣ إنشاء فهارس إضافية للأداء
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated ON public.conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_student_progress_completed ON public.student_progress(is_completed);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON public.enrollments(status);
CREATE INDEX IF NOT EXISTS idx_discussions_parent ON public.discussions(parent_id);

-- ==========================================
-- ✅ تم! المنصة الآن 100% جاهزة
-- ==========================================
