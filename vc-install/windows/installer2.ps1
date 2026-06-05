# Ejecutar c# Ejecutar como Administrador
$ErrorActionPreference = "Stop"
trap { Write-Host "[ERROR] $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

# --- Funcion auxiliar para instalar herramientas con winget ---
function Install-WingetPackageIfMissing {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )
    Write-Host "[...] Comprobando $DisplayName..." -ForegroundColor Gray
    $installed = winget list --id $PackageId --source winget --disable-interactivity 2>$null | Select-String $PackageId
    if ($installed) {
        Write-Host "[OK] $DisplayName ya instalado" -ForegroundColor Green
    } else {
        Write-Host "[INSTALANDO] $DisplayName..." -ForegroundColor Cyan
        winget install --id $PackageId --scope machine --silent `
            --accept-package-agreements --accept-source-agreements `
            --disable-interactivity
        if ($LASTEXITCODE -ne 0) { throw "Fallo al instalar $DisplayName (codigo $LASTEXITCODE)" }
        Write-Host "[OK] $DisplayName instalado correctamente" -ForegroundColor Green
    }
}

# --- Funcion auxiliar para añadir al PATH de maquina sin duplicados ---
function Add-ToMachinePath {
    param([string]$NewPath)
    $machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    if ($machinePath -notlike "*$NewPath*") {
        [Environment]::SetEnvironmentVariable("PATH", $machinePath + ";$NewPath", "Machine")
        Write-Host "[PATH] Añadido: $NewPath" -ForegroundColor Cyan
    } else {
        Write-Host "[PATH] Ya existia: $NewPath" -ForegroundColor Green
    }
    # Aplicar tambien a la sesion actual si no esta
    if ($env:PATH -notlike "*$NewPath*") {
        $env:PATH += ";$NewPath"
    }
}

# --- Directorio CMSIS ---
Write-Host "[PASO 1/10] Comprobando directorio CMSIS..." -ForegroundColor Magenta
if (Test-Path "C:\ARM-Shared\Packs") {
    Write-Host "[OK] Directorio ya existe: C:\ARM-Shared\Packs" -ForegroundColor Green
} else {
    New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\Packs" | Out-Null
    Write-Host "[CREADO] Directorio: C:\ARM-Shared\Packs" -ForegroundColor Cyan
}

# Crear directorio de descargas si no existe
if (-not (Test-Path "C:\ARM-Shared\downloads")) {
    New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\downloads" | Out-Null
    Write-Host "[CREADO] Directorio: C:\ARM-Shared\downloads" -ForegroundColor Cyan
}

# --- Variable de entorno CMSIS_PACK_ROOT ---
Write-Host "[PASO 2/10] Comprobando variable CMSIS_PACK_ROOT..." -ForegroundColor Magenta
$currentVar = [System.Environment]::GetEnvironmentVariable("CMSIS_PACK_ROOT", "Machine")
if ($currentVar -eq "C:\ARM-Shared\Packs") {
    Write-Host "[OK] Variable CMSIS_PACK_ROOT ya configurada" -ForegroundColor Green
} else {
    [System.Environment]::SetEnvironmentVariable("CMSIS_PACK_ROOT", "C:\ARM-Shared\Packs", "Machine")
    Write-Host "[CONFIGURADA] Variable CMSIS_PACK_ROOT" -ForegroundColor Cyan
}
$env:CMSIS_PACK_ROOT = "C:\ARM-Shared\Packs"

# --- Permisos ---
Write-Host "[PASO 3/10] Aplicando permisos..." -ForegroundColor Magenta
icacls "C:\ARM-Shared\Packs" /grant "*S-1-5-32-545:(OI)(CI)M" /T | Out-Null
icacls "C:\ARM-Shared\Packs" /grant "*S-1-5-32-544:(OI)(CI)F" /T | Out-Null
Write-Host "[OK] Permisos aplicados" -ForegroundColor Green

# --- CMSIS-Toolbox ---
Write-Host "[PASO 4/10] Comprobando CMSIS-Toolbox..." -ForegroundColor Magenta
$toolboxZip = "C:\ARM-Shared\downloads\cmsis-toolbox-windows-amd64.zip"
$toolboxDir = "C:\ARM-Shared\cmsis-toolbox-windows-amd64"
$toolboxBin = "$toolboxDir\bin"

if (Test-Path $toolboxBin) {
    Write-Host "[OK] CMSIS-Toolbox ya extraido" -ForegroundColor Green
} else {
    if (-not (Test-Path $toolboxZip)) {
        Write-Host "[...] Descargando CMSIS-Toolbox..." -ForegroundColor Gray
        Invoke-WebRequest -Uri https://artifacts.tools.arm.com/cmsis-toolbox/2.13.0/cmsis-toolbox-windows-amd64.zip -OutFile $toolboxZip -UseBasicParsing
        Write-Host "[OK] Descarga completada" -ForegroundColor Green
    } else {
        Write-Host "[OK] ZIP ya descargado, omitiendo descarga" -ForegroundColor Green
    }
    Write-Host "[...] Extrayendo ZIP..." -ForegroundColor Gray
    tar -xf $toolboxZip -C "C:\ARM-Shared\"
    Write-Host "[OK] CMSIS-Toolbox extraido" -ForegroundColor Green
}

Add-ToMachinePath $toolboxBin

# --- CMake ---
# Nota: winget instala CMake a nivel de maquina, accesible para todos los usuarios
Write-Host "[PASO 5/10] Comprobando CMake..." -ForegroundColor Magenta
Install-WingetPackageIfMissing "Kitware.CMake" "CMake"

# --- Ninja ---
# Nota: winget instala Ninja a nivel de maquina, accesible para todos los usuarios
Write-Host "[PASO 6/10] Comprobando Ninja..." -ForegroundColor Magenta
Install-WingetPackageIfMissing "Ninja-build.Ninja" "Ninja"

# --- Arm Compiler 6 (AC6) ---
# Nota: actualizar $ac6VersionBuild segun la build disponible en:
# https://artifacts.tools.arm.com/arm-compiler/<version>/
$ac6Version      = "6.24"
$ac6VersionBuild = "19"
$ac6Zip          = "C:\ARM-Shared\downloads\armclang-$ac6Version-windows.zip"
$ac6Dir          = "C:\ARM-Shared\ArmCompilerforEmbedded"
$ac6Bin          = "$ac6Dir\bin"

Write-Host "[PASO 7/10] Comprobando Arm Compiler 6 (AC6)..." -ForegroundColor Magenta
if (-not (Test-Path "$ac6Bin\armclang.exe")) {
    if (-not (Test-Path $ac6Zip)) {
        Write-Host "[...] Descargando Arm Compiler 6 $ac6Version (build $ac6VersionBuild)..." -ForegroundColor Gray
        Invoke-WebRequest -Uri "https://artifacts.tools.arm.com/arm-compiler/$ac6Version/$ac6VersionBuild/standalone-win-x86_64-rel.zip" -OutFile $ac6Zip -UseBasicParsing
        Write-Host "[OK] Descarga completada" -ForegroundColor Green
    } else {
        Write-Host "[OK] ZIP ya descargado, omitiendo descarga" -ForegroundColor Green
    }
    Write-Host "[...] Extrayendo Arm Compiler 6..." -ForegroundColor Gray
    New-Item -ItemType Directory -Force -Path $ac6Dir | Out-Null
	$sevenZip = "C:\Program Files\7-Zip\7z.exe"
    #tar -xf $ac6Zip -C $ac6Dir --strip-components=1
	#Expand-Archive -Path $ac6Zip -DestinationPath $ac6Dir -Force
    & $sevenZip x $ac6Zip -o"$ac6Dir" -y | Out-Null
    # Permisos para todos los usuarios
    #icacls $ac6Dir /grant "*S-1-5-32-545:(OI)(CI)RX" /T | Out-Null
    #icacls $ac6Dir /grant "*S-1-5-32-544:(OI)(CI)F" /T | Out-Null

    Add-ToMachinePath $ac6Bin
    Write-Host "[OK] Arm Compiler 6 instalado en $ac6Dir" -ForegroundColor Green
} else {
    Add-ToMachinePath $ac6Bin  # asegurar PATH tambien en ejecuciones posteriores
    Write-Host "[OK] Arm Compiler 6 ya instalado" -ForegroundColor Green
}

# Registrar variable de entorno para CMSIS-Toolbox
$ac6EnvVar = "AC6_TOOLCHAIN_" + $ac6Version.Replace(".", "_")
[Environment]::SetEnvironmentVariable($ac6EnvVar, $ac6Bin, "Machine")
Set-Item -Path "env:$ac6EnvVar" -Value $ac6Bin
Write-Host "[OK] Variable $ac6EnvVar configurada: $ac6Bin" -ForegroundColor Green

# --- Recargar PATH ---
Write-Host "[INFO] Recargando PATH..." -ForegroundColor Yellow
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

# --- Verificar cpackget ---
Write-Host "[INFO] Verificando cpackget..." -ForegroundColor Yellow
if (-not (Get-Command cpackget -ErrorAction SilentlyContinue)) {
    throw "cpackget no encontrado en PATH. Cierra y vuelve a abrir PowerShell como Administrador."
}
Write-Host "[OK] cpackget encontrado" -ForegroundColor Green

# --- cpackget init ---
Write-Host "[PASO 8/10] Comprobando inicializacion de cpackget..." -ForegroundColor Magenta
$indexFile = "$env:CMSIS_PACK_ROOT\.Web\index.pidx"
if (Test-Path $indexFile) {
    Write-Host "[OK] cpackget ya inicializado" -ForegroundColor Green
} else {
    Write-Host "[INICIANDO] cpackget init..." -ForegroundColor Cyan
    cpackget init https://www.keil.com/pack/index.pidx
    if ($LASTEXITCODE -ne 0) { throw "Fallo en cpackget init (codigo $LASTEXITCODE)" }
    Write-Host "[OK] cpackget inicializado" -ForegroundColor Green
}

# --- Funcion auxiliar packs CMSIS ---
function Install-CmsisPackIfMissing {
    param(
        [string]$Vendor,
        [string]$Pack,
        [string]$Version
    )
    Write-Host "[...] Comprobando pack $Vendor::$Pack@$Version..." -ForegroundColor Gray
    $packPath = "$env:CMSIS_PACK_ROOT\$Vendor\$Pack\$Version"
    if (Test-Path $packPath) {
        Write-Host "[OK] Pack ya instalado: $Vendor::$Pack@$Version" -ForegroundColor Green
    } else {
        Write-Host "[INSTALANDO] $Vendor::${Pack}@$Version..." -ForegroundColor Cyan
        cpackget add "$Vendor::${Pack}@$Version"
        if ($LASTEXITCODE -ne 0) { throw "Fallo al instalar pack $Vendor::${Pack}@$Version (codigo $LASTEXITCODE)" }
        Write-Host "[OK] Pack instalado: $Vendor::$Pack@$Version" -ForegroundColor Green
    }
}

# --- CMSIS Packs ---
Write-Host "[PASO 9/10] Instalando CMSIS Packs..." -ForegroundColor Magenta
Install-CmsisPackIfMissing -Vendor "ARM"  -Pack "CMSIS"         -Version "6.3.0"
Install-CmsisPackIfMissing -Vendor "Keil" -Pack "STM32F4xx_DFP" -Version "2.17.1"
Install-CmsisPackIfMissing -Vendor "ARM"  -Pack "CMSIS-Driver"  -Version "2.10.0"
Install-CmsisPackIfMissing -Vendor "ARM"  -Pack "CMSIS-RTX"     -Version "5.9.1"
Install-CmsisPackIfMissing -Vendor "Keil" -Pack "MDK-Middleware" -Version "8.1.0"
Write-Host "[INFO] Lista de packs instalados:" -ForegroundColor Yellow
cpackget list

# --- Visual Studio Code y extensiones ---
Write-Host "[PASO 10/10] Comprobando Visual Studio Code..." -ForegroundColor Magenta
Install-WingetPackageIfMissing "Microsoft.VisualStudioCode" "Visual Studio Code"

Write-Host "[INFO] Recargando PATH para VS Code..." -ForegroundColor Yellow
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

# Buscar code.cmd en rutas conocidas si no esta en PATH
if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    $codePaths = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin",
        "$env:ProgramFiles\Microsoft VS Code\bin",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin"
    )
    foreach ($p in $codePaths) {
        if (Test-Path "$p\code.cmd") {
            $env:PATH += ";$p"
            Write-Host "[INFO] VS Code encontrado en: $p" -ForegroundColor Yellow
            break
        }
    }
}

if (-not (Get-Command code -ErrorAction SilentlyContinue)) {
    throw "'code' no encontrado en PATH. Cierra y vuelve a abrir PowerShell para instalar las extensiones."
}

# --- Extensiones de VS Code ---
function Install-VSCodeExtensionIfMissing {
    param([string]$ExtensionId)
    Write-Host "[...] Comprobando extension $ExtensionId..." -ForegroundColor Gray
    $installed = code --list-extensions 2>$null | Select-String $ExtensionId
    if ($installed) {
        Write-Host "[OK] Extension ya instalada: $ExtensionId" -ForegroundColor Green
    } else {
        Write-Host "[INSTALANDO] Extension: $ExtensionId..." -ForegroundColor Cyan
        code --install-extension $ExtensionId --force
        if ($LASTEXITCODE -ne 0) { throw "Fallo al instalar extension $ExtensionId (codigo $LASTEXITCODE)" }
        Write-Host "[OK] Extension instalada: $ExtensionId" -ForegroundColor Green
    }
}

Install-VSCodeExtensionIfMissing "Arm.keil-studio-pack"
Install-VSCodeExtensionIfMissing "ms-vscode.cpptools"
Install-VSCodeExtensionIfMissing "ms-vscode.cmake-tools"
Install-VSCodeExtensionIfMissing "marus25.cortex-debug"

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  Instalacion completada correctamente" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host "  Reinicia el equipo o abre una nueva" -ForegroundColor Yellow
Write-Host "  sesion para que todos los PATH y" -ForegroundColor Yellow
Write-Host "  variables de entorno tomen efecto." -ForegroundColor Yellow
Write-Host "===========================================" -ForegroundColor Green