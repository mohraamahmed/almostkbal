# PowerShell script to fix all motion components with className
Write-Host "Fixing all motion components with className..." -ForegroundColor Green

# List of files with motion.className issues
$files = @(
    "D:\almostkbal\src\app\page.tsx",
    "D:\almostkbal\src\app\admin\page.tsx",
    "D:\almostkbal\src\app\admin\analytics\page.tsx",
    "D:\almostkbal\src\app\admin\dashboard\page.tsx",
    "D:\almostkbal\src\app\admin\exams\page.tsx",
    "D:\almostkbal\src\app\admin\teachers\page.tsx",
    "D:\almostkbal\src\app\certificates\generate\page.tsx",
    "D:\almostkbal\src\app\courses\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\checkout\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\exams\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\learn\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\payment\page.tsx",
    "D:\almostkbal\src\app\courses\[id]\qa\page.tsx",
    "D:\almostkbal\src\app\dashboard\page.tsx",
    "D:\almostkbal\src\app\library\page.tsx",
    "D:\almostkbal\src\app\library\upload\page.tsx",
    "D:\almostkbal\src\app\login\page.tsx",
    "D:\almostkbal\src\app\notifications\page.tsx",
    "D:\almostkbal\src\app\privacy\page.tsx",
    "D:\almostkbal\src\app\register\page.tsx",
    "D:\almostkbal\src\app\settings\page.tsx",
    "D:\almostkbal\src\app\student\dashboard\page.tsx",
    "D:\almostkbal\src\app\teachers\courses\create\page.tsx",
    "D:\almostkbal\src\app\teachers\dashboard\page.tsx",
    "D:\almostkbal\src\app\teachers\upload\page.tsx",
    "D:\almostkbal\src\app\terms\page.tsx",
    "D:\almostkbal\src\components\*.tsx"
)

$totalFixed = 0

foreach ($filePattern in $files) {
    $filePaths = Get-ChildItem -Path $filePattern -ErrorAction SilentlyContinue
    
    foreach ($file in $filePaths) {
        if (Test-Path $file.FullName) {
            Write-Host "Checking: $($file.Name)" -ForegroundColor Yellow
            $content = Get-Content $file.FullName | Out-String
            $originalContent = $content
            
            # Pattern to find motion components with className
            # This regex is complex but handles most cases
            $pattern = '(<motion\.(\w+)[^>]*?)(\s+className\s*=\s*["{][^"}]+["}])([^>]*>)'
            
            # Replace with wrapped version
            $replacement = '$1$4`n  <div className=$3>`n    '
            
            # Apply the fix
            $newContent = $content -replace $pattern, $replacement
            
            if ($newContent -ne $originalContent) {
                # Save the fixed content
                Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
                Write-Host "  ✓ Fixed $($file.Name)" -ForegroundColor Green
                $totalFixed++
            }
        }
    }
}

Write-Host "`nTotal files fixed: $totalFixed" -ForegroundColor Cyan
Write-Host "Run 'npm run build' to verify all fixes" -ForegroundColor Yellow
