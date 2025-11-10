-- ==========================================
-- 🔥 الخطوة 1: حذف السياسات القديمة
-- شغل هذا أولاً ثم شغل الملف الآخر
-- ==========================================

-- تعطيل وحذف RLS من كل الجداول الموجودة
DO $$ 
DECLARE 
    pol record;
    tbl record;
BEGIN
    -- حذف كل السياسات من كل الجداول
    FOR pol IN 
        SELECT schemaname, tablename, policyname
        FROM pg_policies 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
            pol.policyname, pol.schemaname, pol.tablename);
    END LOOP;
    
    -- تعطيل RLS من كل الجداول
    FOR tbl IN 
        SELECT tablename 
        FROM pg_tables 
        WHERE schemaname = 'public'
    LOOP
        EXECUTE format('ALTER TABLE IF EXISTS public.%I DISABLE ROW LEVEL SECURITY', 
            tbl.tablename);
    END LOOP;
END $$;

-- ==========================================
-- ✅ تم حذف كل السياسات وتعطيل RLS
-- ==========================================

-- الآن شغل: SUPABASE_FINAL_WORKING.sql
