@echo off
setlocal enabledelayedexpansion

:: 1. Input folder
set /p "INPUT_DIR=📂 Masukkan path folder: "
set "INPUT_DIR=%INPUT_DIR:"=%"

:: Cek apakah folder ada
if not exist "%INPUT_DIR%" (
    echo ❌ Folder tidak ditemukan!
    pause
    exit /b
)

set "OUTPUT_DIR=%INPUT_DIR%\converted"
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

echo 🚀 Memulai konversi semua file di: "%INPUT_DIR%"
echo --------------------------------------------------

:: 2. Gunakan perintah 'FORFILES' agar lebih akurat membaca daftar file
:: Kita akan melakukan loop untuk setiap file yang ditemukan di folder tersebut
for /f "delims=" %%i in ('dir /b /a-d "%INPUT_DIR%"') do (
    set "filename=%%~ni"
    set "ext=%%~xi"
    
    :: Cek apakah filenya adalah video (tambahkan ekstensi lain jika perlu)
    set "isvideo=false"
    for %%v in (.mp4 .mkv .avi .mov .flv .wmv .webm .ts) do (
        if /i "%%~xi"=="%%v" set "isvideo=true"
    )

    if "!isvideo!"=="true" (
        echo 🎬 Sedang memproses: "%%i"
        
        ffmpeg -y -i "%INPUT_DIR%\%%i" ^
          -c:v libx264 -profile:v main -level 4.0 -preset fast -crf 23 ^
          -c:a libmp3lame -b:a 192k ^
          -vf "scale='min(1920,iw)':'min(1080,ih)':force_original_aspect_ratio=decrease,fps=30" ^
          "%OUTPUT_DIR%\!filename!.mp4" -loglevel error

        if !errorlevel! equ 0 (
            echo ✅ Selesai: "!filename!.mp4"
        ) else (
            echo ❌ Gagal mengonversi: "%%i"
        )
        echo --------------------------------------------------
    )
)

echo ✨ Semua file video yang didukung telah diproses!
echo 📂 Lokasi hasil: "%OUTPUT_DIR%"
pause