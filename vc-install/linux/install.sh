#!/usr/bin/env bash
# =============================================================================
# installer_linux.sh
# SBM - Sistemas Basados en Microprocesador (UPM)
#
# Uso: sudo bash installer_linux.sh
# Probado en: Ubuntu 22.04 / 24.04 LTS (x86_64)
# =============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[0;35m'; GRAY='\033[0;37m'
BOLD='\033[1m'; NC='\033[0m'

log_ok()      { echo -e "${GREEN}[OK]${NC} $*"; }
log_info()    { echo -e "${GRAY}[...]${NC} $*"; }
log_install() { echo -e "${CYAN}[INSTALANDO]${NC} $*"; }
log_step()    { echo -e "\n${MAGENTA}${BOLD}$*${NC}"; }
log_warn()    { echo -e "${YELLOW}[INFO]${NC} $*"; }
log_err()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Comprobar root ────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    log_err "Ejecuta este script como root: sudo bash installer_linux.sh"
fi

# ── Versiones ─────────────────────────────────────────────────────────────────
TOOLBOX_VERSION="2.14.1"
TOOLBOX_TARBALL="cmsis-toolbox-linux-amd64.tar.gz"
TOOLBOX_URL="https://artifacts.tools.arm.com/cmsis-toolbox/${TOOLBOX_VERSION}/${TOOLBOX_TARBALL}"

AC6_VERSION="6.24"
AC6_BUILD="19"
AC6_TARBALL="standalone-linux-x86_64-rel.tar.gz"
AC6_URL="https://artifacts.tools.arm.com/arm-compiler/${AC6_VERSION}/${AC6_BUILD}/${AC6_TARBALL}"

# FIX 1: AC6_TOOLCHAIN requiere major_minor_patch → añadir _0 al final
AC6_ENV_VAR="AC6_TOOLCHAIN_$(echo ${AC6_VERSION} | tr '.' '_')_0"   # AC6_TOOLCHAIN_6_24_0

# ── Rutas base ────────────────────────────────────────────────────────────────
ARM_BASE="/opt/ARM-Shared"
PACKS_DIR="${ARM_BASE}/Packs"
DOWNLOADS_DIR="${ARM_BASE}/downloads"
TOOLBOX_DIR="${ARM_BASE}/cmsis-toolbox-linux-amd64"
TOOLBOX_BIN="${TOOLBOX_DIR}/bin"
AC6_DIR="${ARM_BASE}/ArmCompilerforEmbedded"
AC6_BIN="${AC6_DIR}/bin"

ENV_PROFILE="/etc/profile.d/sbm-rtos.sh"

# Usuario real que invocó sudo
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(eval echo "~${REAL_USER}")

# ── Función: añadir al PATH del sistema sin duplicados ───────────────────────
add_to_system_path() {
    local new_path="$1"
    if grep -qF "export PATH.*${new_path}" "${ENV_PROFILE}" 2>/dev/null; then
        log_ok "Ya en PATH: ${new_path}"
    else
        echo "export PATH=\"${new_path}:\$PATH\"" >> "${ENV_PROFILE}"
        log_info "Añadido al PATH: ${new_path}"
    fi
    export PATH="${new_path}:${PATH}"
}

# ── Función: establecer variable de entorno del sistema ──────────────────────
set_system_env() {
    local var="$1"
    local val="$2"
    if grep -qF "export ${var}=" "${ENV_PROFILE}" 2>/dev/null; then
        sed -i "s|export ${var}=.*|export ${var}=\"${val}\"|" "${ENV_PROFILE}"
    else
        echo "export ${var}=\"${val}\"" >> "${ENV_PROFILE}"
    fi
    export "${var}=${val}"
    log_info "Variable ${var} configurada: ${val}"
}

# ── Función: descargar sólo si no existe ya ──────────────────────────────────
download_if_missing() {
    local url="$1"
    local dest="$2"
    if [[ -f "${dest}" ]]; then
        log_ok "Fichero ya descargado, omitiendo: $(basename ${dest})"
    else
        log_info "Descargando $(basename ${dest})..."
        wget --quiet --show-progress -O "${dest}" "${url}" \
            || log_err "Fallo al descargar ${url}"
        log_ok "Descarga completada"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# PASO 1/10 — Directorios base
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 1/10] Comprobando directorios base..."

for dir in "${PACKS_DIR}" "${DOWNLOADS_DIR}"; do
    if [[ -d "${dir}" ]]; then
        log_ok "Directorio ya existe: ${dir}"
    else
        mkdir -p "${dir}"
        log_info "Creado: ${dir}"
    fi
done

touch "${ENV_PROFILE}"
chmod 644 "${ENV_PROFILE}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 2/10 — Variable CMSIS_PACK_ROOT
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 2/10] Comprobando variable CMSIS_PACK_ROOT..."
set_system_env "CMSIS_PACK_ROOT" "${PACKS_DIR}"
log_ok "CMSIS_PACK_ROOT=${PACKS_DIR}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 3/10 — Permisos
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 3/10] Aplicando permisos..."

chown -R root:users "${PACKS_DIR}" 2>/dev/null || chown -R root:root "${PACKS_DIR}"
chmod -R 775 "${PACKS_DIR}"
log_ok "Permisos aplicados en ${PACKS_DIR}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 4/10 — CMSIS-Toolbox
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 4/10] Comprobando CMSIS-Toolbox ${TOOLBOX_VERSION}..."

if [[ -x "${TOOLBOX_BIN}/cpackget" ]]; then
    log_ok "CMSIS-Toolbox ya instalado en ${TOOLBOX_DIR}"
else
    download_if_missing "${TOOLBOX_URL}" "${DOWNLOADS_DIR}/${TOOLBOX_TARBALL}"

    log_info "Extrayendo CMSIS-Toolbox..."
    tar -xf "${DOWNLOADS_DIR}/${TOOLBOX_TARBALL}" -C "${ARM_BASE}/"

    FOUND_TOOLBOX_BIN=$(find "${ARM_BASE}" -maxdepth 4 -type f -name "cpackget" -exec dirname {} \; | head -1)
    if [[ -z "${FOUND_TOOLBOX_BIN}" ]]; then
        log_err "No se encontro cpackget tras la extraccion."
    fi
    if [[ "${FOUND_TOOLBOX_BIN}" != "${TOOLBOX_BIN}" ]]; then
        log_warn "bin real detectado en: ${FOUND_TOOLBOX_BIN} (esperado: ${TOOLBOX_BIN})"
        TOOLBOX_BIN="${FOUND_TOOLBOX_BIN}"
    fi
    chmod -R +x "${TOOLBOX_BIN}"
    log_ok "CMSIS-Toolbox extraido (bin: ${TOOLBOX_BIN})"
fi

add_to_system_path "${TOOLBOX_BIN}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 5/10 — CMake
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 5/10] Comprobando CMake..."

if command -v cmake &>/dev/null; then
    log_ok "CMake ya instalado: $(cmake --version | head -1)"
else
    log_install "CMake..."
    apt-get update -qq
    apt-get install -y cmake
    log_ok "CMake instalado: $(cmake --version | head -1)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 6/10 — Ninja
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 6/10] Comprobando Ninja..."

if command -v ninja &>/dev/null; then
    log_ok "Ninja ya instalado: $(ninja --version)"
else
    log_install "Ninja..."
    apt-get install -y ninja-build
    log_ok "Ninja instalado: $(ninja --version)"
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 7/10 — Arm Compiler 6 (AC6)
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 7/10] Comprobando Arm Compiler 6 (AC6) ${AC6_VERSION}..."

if [[ -x "${AC6_BIN}/armclang" ]]; then
    log_ok "Arm Compiler 6 ya instalado"
else
    download_if_missing "${AC6_URL}" "${DOWNLOADS_DIR}/${AC6_TARBALL}"

    log_info "Extrayendo Arm Compiler 6..."
    mkdir -p "${AC6_DIR}"
    tar -xf "${DOWNLOADS_DIR}/${AC6_TARBALL}" -C "${AC6_DIR}"

    FOUND_BIN=$(find "${AC6_DIR}" -maxdepth 3 -type f -name "armclang" -exec dirname {} \; | head -1)
    if [[ -z "${FOUND_BIN}" ]]; then
        log_err "No se encontro armclang tras la extraccion en ${AC6_DIR}."
    fi
    if [[ "${FOUND_BIN}" != "${AC6_BIN}" ]]; then
        log_warn "bin real detectado en: ${FOUND_BIN} (esperado: ${AC6_BIN})"
        AC6_BIN="${FOUND_BIN}"
    fi
    chmod -R +x "${AC6_BIN}"
    log_ok "Arm Compiler 6 instalado en ${AC6_DIR} (bin: ${AC6_BIN})"
fi

add_to_system_path "${AC6_BIN}"

# FIX 1: Variable con formato correcto major_minor_patch (AC6_TOOLCHAIN_6_24_0)
set_system_env "${AC6_ENV_VAR}" "${AC6_BIN}"
log_ok "Variable ${AC6_ENV_VAR} configurada: ${AC6_BIN}"

# ─────────────────────────────────────────────────────────────────────────────
# FIX 2: Cargar variables en .bashrc del usuario para VS Code
# /etc/profile.d/ solo se carga en login shells, no en VS Code terminal
# ─────────────────────────────────────────────────────────────────────────────
log_step "Configurando variables en perfil de usuario ${REAL_USER}..."

USER_BASHRC="${REAL_HOME}/.bashrc"

if ! grep -qF "sbm-rtos.sh" "${USER_BASHRC}" 2>/dev/null; then
    echo "" >> "${USER_BASHRC}"
    echo "# SBM-RTOS tools (añadido por installer_linux.sh)" >> "${USER_BASHRC}"
    echo "if [ -f /etc/profile.d/sbm-rtos.sh ]; then" >> "${USER_BASHRC}"
    echo "    source /etc/profile.d/sbm-rtos.sh" >> "${USER_BASHRC}"
    echo "fi" >> "${USER_BASHRC}"
    log_ok "Source de sbm-rtos.sh añadido a ${USER_BASHRC}"
else
    log_ok "Ya configurado en ${USER_BASHRC}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Verificar cpackget accesible en PATH
# ─────────────────────────────────────────────────────────────────────────────
log_warn "Verificando cpackget..."

if ! command -v cpackget &>/dev/null; then
    log_err "cpackget no encontrado en PATH. Cierra y vuelve a abrir la terminal."
fi
log_ok "cpackget encontrado: $(which cpackget)"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 8/10 — cpackget init
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 8/10] Comprobando inicialización de cpackget..."

INDEX_FILE="${PACKS_DIR}/.Web/index.pidx"

if [[ -f "${INDEX_FILE}" ]]; then
    log_ok "cpackget ya inicializado"
else
    log_install "cpackget init..."
    cpackget init https://www.keil.com/pack/index.pidx
    log_ok "cpackget inicializado"
fi

# ── Función: instalar CMSIS pack si no existe ─────────────────────────────────
install_cmsis_pack() {
    local vendor="$1"
    local pack="$2"
    local version="$3"
    local pack_path="${PACKS_DIR}/${vendor}/${pack}/${version}"

    log_info "Comprobando pack ${vendor}::${pack}@${version}..."
    if [[ -d "${pack_path}" ]]; then
        log_ok "Pack ya instalado: ${vendor}::${pack}@${version}"
    else
        log_install "${vendor}::${pack}@${version}..."
        # FIX 3: Añadir --agree-embedded-license para evitar prompts interactivos
        cpackget add "${vendor}::${pack}@${version}" --agree-embedded-license
        log_ok "Pack instalado: ${vendor}::${pack}@${version}"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# PASO 9/10 — CMSIS Packs
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 9/10] Instalando CMSIS Packs..."

install_cmsis_pack "ARM"  "CMSIS"          "6.3.0"
install_cmsis_pack "Keil" "STM32F4xx_DFP"  "2.17.1"
install_cmsis_pack "ARM"  "CMSIS-Driver"   "2.10.0"
# FIX 4: Nombre correcto del pack RTX → CMSIS-RTX5 (no CMSIS-RTX)
install_cmsis_pack "ARM"  "CMSIS-RTX"     "5.9.1"
install_cmsis_pack "Keil" "MDK-Middleware"  "8.1.0"

log_warn "Lista de packs instalados:"
cpackget list

# ─────────────────────────────────────────────────────────────────────────────
# PASO 10/10 — Visual Studio Code y extensiones
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 10/10] Comprobando Visual Studio Code..."

if command -v code &>/dev/null; then
    log_ok "VS Code ya instalado: $(code --version | head -1)"
else
    log_install "Visual Studio Code..."
    apt-get install -y wget gpg
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
        | gpg --dearmor > /usr/share/keyrings/microsoft.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
        > /etc/apt/sources.list.d/vscode.list
    apt-get update -qq
    apt-get install -y code
    log_ok "VS Code instalado"
fi

# ── Extensiones de VS Code ────────────────────────────────────────────────────
install_vscode_extension() {
    local ext_id="$1"
    log_info "Comprobando extensión ${ext_id}..."
    if sudo -u "${REAL_USER}" code --list-extensions 2>/dev/null | grep -qi "^${ext_id}$"; then
        log_ok "Extensión ya instalada: ${ext_id}"
    else
        log_install "Extensión: ${ext_id}..."
        sudo -u "${REAL_USER}" code --install-extension "${ext_id}" --force
        log_ok "Extensión instalada: ${ext_id}"
    fi
}

install_vscode_extension "Arm.keil-studio-pack"
install_vscode_extension "ms-vscode.cpptools"
install_vscode_extension "ms-vscode.cmake-tools"
install_vscode_extension "marus25.cortex-debug"

# ─────────────────────────────────────────────────────────────────────────────
# FIX 5: Generar VS Code settings globales con variables de entorno
# Necesario porque VS Code no carga /etc/profile.d/ en terminal integrada
# ─────────────────────────────────────────────────────────────────────────────
log_step "Configurando VS Code settings globales para ${REAL_USER}..."

VSCODE_SETTINGS_DIR="${REAL_HOME}/.config/Code/User"
VSCODE_SETTINGS="${VSCODE_SETTINGS_DIR}/settings.json"
mkdir -p "${VSCODE_SETTINGS_DIR}"

# Crear settings.json si no existe
if [[ ! -f "${VSCODE_SETTINGS}" ]]; then
    echo "{}" > "${VSCODE_SETTINGS}"
fi

# Inyectar variables de entorno usando python3
python3 - <<EOF
import json

settings_file = "${VSCODE_SETTINGS}"
with open(settings_file, 'r') as f:
    try:
        settings = json.load(f)
    except json.JSONDecodeError:
        settings = {}

settings["terminal.integrated.env.linux"] = {
    "CMSIS_PACK_ROOT": "${PACKS_DIR}",
    "${AC6_ENV_VAR}": "${AC6_BIN}",
    "PATH": "${AC6_BIN}:${TOOLBOX_BIN}:\${env:PATH}"
}

settings["cmake.environment"] = {
    "CMSIS_PACK_ROOT": "${PACKS_DIR}",
    "${AC6_ENV_VAR}": "${AC6_BIN}"
}

# Deshabilitar vcpkg auto-download (herramientas ya instaladas manualmente)
settings["vcpkg.enabled"] = False
settings["arm-tools.autoActivate"] = False

settings["debug.hideSlowPreLaunchWarning"] = True

with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=4)

print("settings.json actualizado correctamente")
EOF

chown "${REAL_USER}:${REAL_USER}" "${VSCODE_SETTINGS}"
log_ok "VS Code settings.json configurado en ${VSCODE_SETTINGS}"


# Descargar el .deb oficial de stlink desde GitHub releases
wget -O /tmp/stlink_1.8.0-1_amd64.deb https://github.com/stlink-org/stlink/releases/download/v1.8.0/stlink_1.8.0-1_amd64.deb

# Instalar
sudo apt-get install /tmp/stlink_1.8.0-1_amd64.deb

# ─────────────────────────────────────────────────────────────────────────────
# FIN
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD}   Instalación completada correctamente      ${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${YELLOW}  Cierra y vuelve a abrir la terminal (o${NC}"
echo -e "${YELLOW}  ejecuta: source ${ENV_PROFILE})${NC}"
echo -e "${YELLOW}  para que PATH y variables tomen efecto.${NC}"
echo -e "${YELLOW}  Lanza VS Code desde terminal:${NC}"
echo -e "${YELLOW}  source ~/.bashrc && code .${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
