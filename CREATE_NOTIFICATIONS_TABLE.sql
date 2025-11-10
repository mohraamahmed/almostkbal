-- إنشاء جدول الإشعارات في Supabase
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  type TEXT DEFAULT 'info' CHECK (type IN ('info', 'success', 'warning', 'error', 'course', 'certificate', 'payment', 'announcement')),
  link TEXT,
  image TEXT,
  is_read BOOLEAN DEFAULT false,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- إضافة فهارس للأداء
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);
CREATE INDEX idx_notifications_is_read ON public.notifications(is_read);

-- تفعيل Realtime
ALTER TABLE public.notifications REPLICA IDENTITY FULL;

-- سياسات الأمان (RLS)
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- السماح للمستخدمين بقراءة إشعاراتهم فقط
CREATE POLICY "Users can read own notifications" ON public.notifications
  FOR SELECT USING (auth.uid()::text = user_id OR user_id = auth.uid()::text);

-- السماح للمستخدمين بتحديث إشعاراتهم (للقراءة)
CREATE POLICY "Users can update own notifications" ON public.notifications
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id = auth.uid()::text);

-- السماح للنظام بإنشاء إشعارات
CREATE POLICY "System can create notifications" ON public.notifications
  FOR INSERT WITH CHECK (true);

-- السماح للمستخدمين بحذف إشعاراتهم
CREATE POLICY "Users can delete own notifications" ON public.notifications
  FOR DELETE USING (auth.uid()::text = user_id OR user_id = auth.uid()::text);
