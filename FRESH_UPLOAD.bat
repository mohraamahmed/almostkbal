@echo off
chcp 65001 > nul
title Fresh Upload Without Video
color 0A

echo ==========================================
echo    Fresh Start - Upload Without Video
echo ==========================================
echo.

cd /d D:\almostkbal

echo Step 1: Removing Git history...
rmdir /s /q .git 2>nul

echo.
echo Step 2: Deleting large video file...
del /f "public\intro-video.mp4" 2>nul

echo.
echo Step 3: Initializing fresh Git...
git init

echo.
echo Step 4: Adding all files...
git add .

echo.
echo Step 5: Creating commit...
git commit -m "Frontend: Educational Platform (clean)"

echo.
echo Step 6: Adding GitHub remote...
git remote add origin https://github.com/mohraamahmed/almostkbal.git

echo.
echo Step 7: Pushing to GitHub (force)...
git branch -M main
git push -u origin main --force

echo.
echo ==========================================
echo SUCCESS! Frontend uploaded without issues!
echo GitHub: https://github.com/mohraamahmed/almostkbal
echo.
echo Next Step: Import in Vercel!
echo ==========================================
pause
