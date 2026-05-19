# Ejecutar como Administrador
$ErrorActionPreference = "Stop"
trap { Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

# --- Funcion auxiliar para desinstalar con winget ---
function Uninstall-WingetPackageIfInstalled {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )
    Write-Host "[...] Comprobando $DisplayName..." -ForegroundColor Gray
    $installed = winget list --id $PackageId --source winget --disable-interactivity 2>$null | Select-String $PackageId
    if ($installed) {
        Write-Host "[DESINSTALANDO] $DisplayName..." -ForegroundColor Cyan
        winget uninstall --id $PackageId --silent --disable-interactivity
        if ($LASTEXITCODE -ne 0) { throw "Fallo al desinstalar $DisplayName (codigo $LASTEXITCODE)" }
        Write-Host "[OK] $DisplayName desinstalado" -ForegroundColor Green
    } else {
        Write-Host "[OK] $DisplayName no estaba instalado" -ForegroundColor Green
    }
}

# --- Funcion auxiliar para limpiar entradas del PATH de maquina ---
function Remove-FromMachinePath {
    param([string]$PathToRemove)
    $machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($machinePath -like "*$PathToRemove*") {
        $newPath = ($machinePath -split ";" | Where-Object { $_ -ne $PathToRemove }) -join ";"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "Machine")
        Write-Host "[PATH] Eliminado: $PathToRemove" -ForegroundColor Cyan
    } else {
        Write-Host "[PATH] No estaba en PATH: $PathToRemove" -ForegroundColor Green
    }
}

# --- CMSIS Packs ---
Write-Host "[PASO 1/6] Eliminando CMSIS Packs..." -ForegroundColor Magenta
if (Get-Command cpackget -ErrorAction SilentlyContinue) {
    $packs = @(
        "ARM::CMSIS-Driver@2.9.0",
        "ARM::CMSIS-RTX@5.9.0",
        "ARM::CMSIS-RTOS2@2.2.0",
        "Keil::MDK-Middleware@8.0.0",
        "Keil::STM32F4xx_DFP@2.17.1",
        "ARM::CMSIS@6.1.0"
    )
    foreach ($pack in $packs) {
        Write-Host "[...] Eliminando pack $pack..." -ForegroundColor Gray
        cpackget rm $pack 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[OK] Pack eliminado: $pack" -ForegroundColor Green
        } else {
            Write-Host "[AVISO] Pack no encontrado o ya eliminado: $pack" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "[AVISO] cpackget no encontrado, omitiendo eliminacion de packs" -ForegroundColor Yellow
}

# --- Directorio CMSIS ---
Write-Host "[PASO 2/6] Eliminando directorio C:\ARM-Shared..." -ForegroundColor Magenta
if (Test-Path "C:\ARM-Shared") {
    Remove-Item "C:\ARM-Shared" -Recurse -Force
    Write-Host "[OK] Directorio C:\ARM-Shared eliminado" -ForegroundColor Green
} else {
    Write-Host "[OK] Directorio C:\ARM-Shared no existia" -ForegroundColor Green
}

# --- Variable de entorno CMSIS_PACK_ROOT ---
Write-Host "[PASO 3/6] Eliminando variable CMSIS_PACK_ROOT..." -ForegroundColor Magenta
if ([System.Environment]::GetEnvironmentVariable("CMSIS_PACK_ROOT", "Machine")) {
    [System.Environment]::SetEnvironmentVariable("CMSIS_PACK_ROOT", $null, "Machine")
    Write-Host "[OK] Variable CMSIS_PACK_ROOT eliminada" -ForegroundColor Green
} else {
    Write-Host "[OK] Variable CMSIS_PACK_ROOT no existia" -ForegroundColor Green
}

# --- PATH ---
Write-Host "[PASO 4/6] Limpiando PATH..." -ForegroundColor Magenta
Remove-FromMachinePath "C:\ARM-Shared\cmsis-toolbox-windows-amd64\bin"

# --- Desinstalar aplicaciones ---
Write-Host "[PASO 5/6] Desinstalando aplicaciones..." -ForegroundColor Magenta
Uninstall-WingetPackageIfInstalled "Arm.GnuArmEmbeddedToolchain" "GNU Arm Embedded Toolchain"
Uninstall-WingetPackageIfInstalled "Ninja-build.Ninja"           "Ninja"
Uninstall-WingetPackageIfInstalled "Kitware.CMake"               "CMake"

# --- VS Code y extensiones ---
Write-Host "[PASO 6/6] Desinstalando extensiones de VS Code..." -ForegroundColor Magenta
if (Get-Command code -ErrorAction SilentlyContinue) {
    $extensions = @(
        "Arm.keil-studio-pack",
        "ms-vscode.cpptools",
        "ms-vscode.cmake-tools"
    )
    foreach ($ext in $extensions) {
        Write-Host "[...] Desinstalando extension $ext..." -ForegroundColor Gray
        code --uninstall-extension $ext 2>$null
        Write-Host "[OK] Extension desinstalada: $ext" -ForegroundColor Green
    }
} else {
    Write-Host "[AVISO] VS Code no encontrado en PATH, omitiendo extensiones" -ForegroundColor Yellow
}

# Preguntar si desinstalar VS Code
Write-Host ""
$resp = Read-Host "¿Desinstalar tambien Visual Studio Code? (s/N)"
if ($resp -eq "s" -or $resp -eq "S") {
    Uninstall-WingetPackageIfInstalled "Microsoft.VisualStudioCode" "Visual Studio Code"
} else {
    Write-Host "[OK] Visual Studio Code conservado" -ForegroundColor Green
}

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  Desinstalacion completada" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  Reinicia el equipo para que los cambios" -ForegroundColor Yellow
Write-Host "  en PATH y variables tomen efecto." -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Green