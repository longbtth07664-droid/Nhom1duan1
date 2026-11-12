@echo off
chcp 65001 >nul
echo ========================================================
echo        DANG COMMIT VA PUSH CODE LEN GITHUB
echo ========================================================

echo.
echo [1/3] Them tat ca thay doi vao Git...
git add .

echo.
echo [2/3] Commit code dang nhap, phan quyen bang Hibernate...
git commit -m "Hoan thien chuc nang dang nhap phan quyen bang Hibernate va dong bo giao dien"

echo.
echo [3/3] Dang day code len nhanh main tren GitHub...
git push origin main

echo.
if %ERRORLEVEL% EQU 0 (
    echo ========================================================
    echo      PUSH CODE LEN GITHUB THANH CONG TOT DEP!
    echo ========================================================
) else (
    echo ========================================================
    echo      CO LOI XAY RA KHI PUSH (Vui long kiem tra lai mang/quyen Git)
    echo ========================================================
)
pause
