-- ==========================================
-- تفعيل Realtime للجداول المهمة
-- انسخ والصق في Supabase SQL Editor
-- ==========================================

-- تفعيل Realtime Publication
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.conversations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.announcements;

-- اختياري - باقي الجداول
ALTER PUBLICATION supabase_realtime ADD TABLE public.enrollments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.student_progress;
ALTER PUBLICATION supabase_realtime ADD TABLE public.discussions;
ALTER PUBLICATION supabase_realtime ADD TABLE public.exam_results;

-- ==========================================
-- ✅ تم! الآن Realtime مفعّل
-- ==========================================
