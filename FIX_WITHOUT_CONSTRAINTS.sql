-- ==========================================
-- 🔧 إصلاح بدون constraints معقدة
-- ==========================================

-- 1️⃣ إضافة الأعمدة الناقصة فقط
ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS last_message_id UUID;

ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- 2️⃣ إضافة حقول إضافية مفيدة
ALTER TABLE public.student_progress 
ADD COLUMN IF NOT EXISTS last_watched TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.enrollments 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.discussions 
ADD COLUMN IF NOT EXISTS parent_id UUID;

-- 3️⃣ إنشاء فهارس للأداء (بدون constraints)
CREATE INDEX IF NOT EXISTS idx_conversations_last_message ON public.conversations(last_message_id);
CREATE INDEX IF NOT EXISTS idx_conversations_updated ON public.conversations(updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_student_progress_completed ON public.student_progress(is_completed);
CREATE INDEX IF NOT EXISTS idx_enrollments_status ON public.enrollments(status);
CREATE INDEX IF NOT EXISTS idx_discussions_parent ON public.discussions(parent_id);
CREATE INDEX IF NOT EXISTS idx_messages_read ON public.messages(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON public.notifications(is_read);

-- ==========================================
-- ✅ تم! المنصة جاهزة الآن
-- ==========================================
