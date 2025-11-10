-- ==========================================
-- إضافة الأعمدة الناقصة فقط - بدون فهارس
-- ==========================================

-- إضافة الأعمدة المهمة لـ conversations
ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS last_message_id UUID;

ALTER TABLE public.conversations 
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- إضافة حقول إضافية مفيدة
ALTER TABLE public.student_progress 
ADD COLUMN IF NOT EXISTS last_watched TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.enrollments 
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.enrollments 
ADD COLUMN IF NOT EXISTS expires_at TIMESTAMP WITH TIME ZONE;

ALTER TABLE public.discussions 
ADD COLUMN IF NOT EXISTS parent_id UUID;

-- ==========================================
-- ✅ تم! فقط إضافة أعمدة بدون أي تعقيدات
-- ==========================================
