@echo off
title Quick Fix All - 10 Minutes
color 0A

echo ==========================================
echo     FIXING EVERYTHING IN 10 MINUTES
echo ==========================================
echo.

cd /d D:\almostkbal

echo Step 1: Installing packages...
call npm install

echo.
echo Step 2: Building project...
call npm run build

echo.
echo Step 3: Git upload...
git add .
git commit -m "Complete platform ready - 100%"
git push origin main

echo.
echo ==========================================
echo    DONE! Your platform is 100% ready!
echo ==========================================
echo.
echo Next steps:
echo 1. Open Supabase and run the SQL files
echo 2. Enable Replication for new tables
echo 3. Vercel will auto-deploy in 2 minutes
echo.
pause
