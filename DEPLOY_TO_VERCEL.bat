@echo off
chcp 65001 >nul
echo ==========================================
echo 🚀 رفع المنصة على Vercel
echo ==========================================
echo.

echo [1/3] إضافة التعديلات...
git add .

echo.
echo [2/3] حفظ التغييرات...
git commit -m "Update database schema and fix issues"

echo.
echo [3/3] رفع على GitHub...
git push origin main

echo.
echo ==========================================
echo ✅ تم! Vercel سيبني المشروع تلقائياً
echo ==========================================
echo.
echo 📍 راقب التقدم على:
echo https://vercel.com/dashboard
echo.
pause
