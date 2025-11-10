@echo off
chcp 65001 > nul
title Remove Large Video
color 0C

echo ==========================================
echo    Removing Large Video File
echo ==========================================
echo.

cd /d D:\almostkbal

echo Removing intro-video.mp4 from Git...
git rm --cached "public/intro-video.mp4"

echo.
echo Deleting file from disk...
del /f "public\intro-video.mp4" 2>nul

echo.
echo Adding to .gitignore...
echo. >> .gitignore
echo # Large video files >> .gitignore
echo public/*.mp4 >> .gitignore
echo public/*.avi >> .gitignore
echo public/*.mov >> .gitignore
echo *.mp4 >> .gitignore
echo *.avi >> .gitignore

echo.
echo Committing changes...
git add .gitignore
git commit -m "Remove large video file and update gitignore"

echo.
echo Pushing to GitHub...
git push -u origin main

echo.
echo ==========================================
echo Done! Video removed successfully!
echo ==========================================
pause
