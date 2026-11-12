@echo off
chcp 65001 >nul
set TARGET=target\DuAnNhom1-1.0-SNAPSHOT
set SRC=src\main\webapp

copy /Y %SRC%\login.jsp %TARGET%\login.jsp >nul
copy /Y %SRC%\index.jsp %TARGET%\index.jsp >nul
copy /Y %SRC%\menuadmin.jsp %TARGET%\menuadmin.jsp >nul
copy /Y %SRC%\menunv.jsp %TARGET%\menunv.jsp >nul
copy /Y %SRC%\WEB-INF\web.xml %TARGET%\WEB-INF\web.xml >nul

echo [XONG] Da cap nhat giao dien vao target thanh cong!
pause
