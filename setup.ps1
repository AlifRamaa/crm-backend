$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "   SalesLead CRM - Backend Initial Setup Wizard           " -ForegroundColor Yellow
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

# Determine target directory
$scriptDir = $PSScriptRoot
if (-not $scriptDir) {
    $scriptDir = (Get-Location).Path
}

# 1. Check Java Environment
Write-Host "[1/4] Memeriksa Instalasi Java Runtime..." -ForegroundColor Cyan
try {
    $javaVer = java -version 2>&1 | Out-String
    if ($LASTEXITCODE -eq 0 -or $javaVer -match "version") {
        Write-Host "  [OK] Java terdeteksi di sistem." -ForegroundColor Green
    } else {
        Write-Host "  [!] Java runtime tidak terdeteksi. Pastikan Java 17+ terpasang di PATH." -ForegroundColor Yellow
    }
} catch {
    Write-Host "  [!] Java runtime tidak terdeteksi. Pastikan Java 17+ terpasang di PATH." -ForegroundColor Yellow
}

Write-Host ""

# 2. Database Configuration Input
Write-Host "[2/4] Konfigurasi Database PostgreSQL" -ForegroundColor Cyan
Write-Host "Masukkan kredensial PostgreSQL lokal Anda (Tekan Enter untuk nilai default):" -ForegroundColor Gray
Write-Host ""

$dbHost = Read-Host "Host PostgreSQL [default: localhost]"
if ([string]::IsNullOrWhiteSpace($dbHost)) {
    $dbHost = "localhost"
}

$dbPort = Read-Host "Port PostgreSQL [default: 5432]"
if ([string]::IsNullOrWhiteSpace($dbPort)) {
    $dbPort = "5432"
}

$dbUser = Read-Host "Username PostgreSQL [default: postgres]"
if ([string]::IsNullOrWhiteSpace($dbUser)) {
    $dbUser = "postgres"
}

$dbName = Read-Host "Nama Database [default: sales_leads]"
if ([string]::IsNullOrWhiteSpace($dbName)) {
    $dbName = "sales_leads"
}

# Prompt password
$dbPass = Read-Host "Password PostgreSQL untuk user '$dbUser'"

Write-Host ""

# 3. Update application.properties
Write-Host "[3/4] Menyimpan konfigurasi ke application.properties..." -ForegroundColor Cyan

$propPath = Join-Path $scriptDir "src\main\resources\application.properties"
if (-not (Test-Path $propPath)) {
    $parentProp = Join-Path $scriptDir "backend\saleslead\src\main\resources\application.properties"
    if (Test-Path $parentProp) {
        $propPath = $parentProp
    }
}

$propLines = @(
    "spring.application.name=saleslead",
    "",
    "server.port=8080",
    "",
    ("spring.datasource.url=jdbc:postgresql://" + $dbHost + ":" + $dbPort + "/" + $dbName),
    ("spring.datasource.username=" + $dbUser),
    ("spring.datasource.password=" + $dbPass),
    "spring.jpa.hibernate.ddl-auto=update",
    "",
    "spring.jpa.show-sql=true",
    "",
    "spring.jpa.properties.hibernate.format_sql=true"
)

$propContent = $propLines -join "`r`n"
Set-Content -Path $propPath -Value $propContent -Encoding UTF8
Write-Host "  [OK] File application.properties berhasil diperbarui!" -ForegroundColor Green

# Optional: Attempt database creation if psql is present
$env:PGPASSWORD = $dbPass
$psqlExe = "psql"
$psqlCmd = Get-Command psql -ErrorAction SilentlyContinue
if (-not $psqlCmd) {
    $fallbackPsql = Get-ChildItem -Path "C:\Program Files\PostgreSQL" -Filter "psql.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
    if ($fallbackPsql) {
        $psqlExe = $fallbackPsql
        $psqlCmd = $true
    }
}

if ($psqlCmd) {
    Write-Host "  Menginisialisasi database '$dbName' via psql..." -ForegroundColor Gray
    try {
        & $psqlExe -h $dbHost -p $dbPort -U $dbUser -c "CREATE DATABASE $dbName;" 2>&1 | Out-Null
        Write-Host "  [OK] Database '$dbName' siap digunakan!" -ForegroundColor Green
    } catch {
        Write-Host "  [INFO] Database '$dbName' sudah ada atau siap digunakan." -ForegroundColor Gray
    }
} else {
    Write-Host "  [INFO] Tips: Pastikan database '$dbName' sudah dibuat di pgAdmin / PostgreSQL Anda." -ForegroundColor Yellow
}

Write-Host ""

# 4. Run Maven clean compile
Write-Host "[4/4] Mengunduh package Maven & Mengompilasi source code..." -ForegroundColor Cyan

$mvnwPath = Join-Path $scriptDir "mvnw.cmd"
if (-not (Test-Path $mvnwPath)) {
    $mvnwPath = Join-Path $scriptDir "backend\saleslead\mvnw.cmd"
}

$compileSuccess = $false
try {
    if (Test-Path $mvnwPath) {
        & $mvnwPath clean compile
        if ($LASTEXITCODE -eq 0) {
            $compileSuccess = $true
        }
    } else {
        mvn clean compile
        if ($LASTEXITCODE -eq 0) {
            $compileSuccess = $true
        }
    }
} catch {
    Write-Host "  [ERROR] Terjadi kendala saat kompilasi." -ForegroundColor Red
}

if ($compileSuccess) {
    Write-Host ""
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host "   SETUP BACKEND BERHASIL DISELESAIKAN!                  " -ForegroundColor Green
    Write-Host "==========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Untuk menjalankan backend kapan saja:" -ForegroundColor White
    Write-Host "  cd backend\saleslead" -ForegroundColor Yellow
    Write-Host "  .\mvnw.cmd spring-boot:run" -ForegroundColor Yellow
    Write-Host ""

    $runChoice = Read-Host "Apakah Anda ingin menjalankan Backend sekarang? (y/n) [default: y]"
    if ([string]::IsNullOrWhiteSpace($runChoice) -or $runChoice.ToLower() -eq 'y') {
        Write-Host ""
        Write-Host "Menjalankan Spring Boot Server..." -ForegroundColor Cyan
        & $mvnwPath spring-boot:run
    }
} else {
    Write-Host ""
    Write-Host "Kompilasi Maven belum berhasil. Periksa pesan error di atas." -ForegroundColor Red
}
