#!/usr/bin/env bash
# =============================================================================
# uninstaller_linux.sh
# Equivalente Linux de uninstaller.ps1
# SBM - Sistemas Basados en Microprocesador (UPM)
#
# Uso: sudo bash uninstaller_linux.sh
# =============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'
YELLOW='\033[1;33m'; MAGENTA='\033[0;35m'; GRAY='\033[0;37m'
BOLD='\033[1m'; NC='\033[0m'

log_ok()      { echo -e "${GREEN}[OK]${NC} $*"; }
log_info()    { echo -e "${GRAY}[...]${NC} $*"; }
log_remove()  { echo -e "${CYAN}[ELIMINANDO]${NC} $*"; }
log_step()    { echo -e "\n${MAGENTA}${BOLD}$*${NC}"; }
log_warn()    { echo -e "${YELLOW}[AVISO]${NC} $*"; }
log_err()     { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ── Comprobar root ────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
    log_err "Ejecuta este script como root: sudo bash uninstaller_linux.sh"
fi

REAL_USER="${SUDO_USER:-$USER}"

# ── Rutas (deben coincidir con las del installer) ────────────────────────────
ARM_BASE="/opt/ARM-Shared"
ENV_PROFILE="/etc/profile.d/sbm-rtos.sh"

# ── Función: eliminar un directorio si existe ─────────────────────────────────
remove_dir() {
    local dir="$1"
    if [[ -d "${dir}" ]]; then
        log_remove "${dir}..."
        rm -rf "${dir}"
        log_ok "Eliminado: ${dir}"
    else
        log_ok "No existia: ${dir}"
    fi
}

# ── Función: preguntar al usuario (s/N) ───────────────────────────────────────
ask_yes_no() {
    local question="$1"
    local answer
    read -rp "$(echo -e "${YELLOW}${question} (s/N): ${NC}")" answer
    [[ "${answer,,}" == "s" ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Confirmacion antes de empezar
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${RED}${BOLD}========================================================${NC}"
echo -e "${RED}${BOLD}   DESINSTALADOR SBM-RTOS - Linux                       ${NC}"
echo -e "${RED}${BOLD}========================================================${NC}"
echo -e "${YELLOW}  Se eliminaran:${NC}"
echo -e "    - Directorio ${ARM_BASE} (CMSIS-Toolbox, AC6, Packs)"
echo -e "    - Variables de entorno en ${ENV_PROFILE}"
echo -e "    - CMake y Ninja (via apt)"
echo -e "    - Extensiones de VS Code (Arm, cpptools, cmake-tools)"
echo -e "    - Repositorio apt de Microsoft VS Code (opcional)"
echo ""

if ! ask_yes_no "Continuar con la desinstalacion?"; then
    echo -e "${GREEN}Desinstalacion cancelada.${NC}"
    exit 0
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 1/6 — Eliminar CMSIS Packs con cpackget
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 1/6] Eliminando CMSIS Packs..."

# Cargar las variables de entorno del instalador para que cpackget funcione
# aunque el usuario no haya reiniciado la sesion
if [[ -f "${ENV_PROFILE}" ]]; then
    # shellcheck source=/dev/null
    source "${ENV_PROFILE}" 2>/dev/null || true
fi

if command -v cpackget &>/dev/null; then
    PACKS=(
        "ARM::CMSIS@6.3.0"
        "ARM::CMSIS-Driver@2.10.0"
        "ARM::CMSIS-RTX@5.9.1"
        "Keil::STM32F4xx_DFP@2.17.1"
        "Keil::MDK-Middleware@8.1.0"
    )
    for pack in "${PACKS[@]}"; do
        log_info "Eliminando pack ${pack}..."
        if cpackget rm "${pack}" 2>/dev/null; then
            log_ok "Pack eliminado: ${pack}"
        else
            log_warn "Pack no encontrado o ya eliminado: ${pack}"
        fi
    done
else
    log_warn "cpackget no encontrado en PATH, omitiendo eliminacion de packs."
    log_warn "Los packs en ${ARM_BASE}/Packs se eliminaran junto con el directorio."
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 2/6 — Eliminar directorio /opt/ARM-Shared
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 2/6] Eliminando directorio ${ARM_BASE}..."

remove_dir "${ARM_BASE}"

# ─────────────────────────────────────────────────────────────────────────────
# PASO 3/6 — Eliminar variables de entorno del sistema
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 3/6] Eliminando variables de entorno..."

if [[ -f "${ENV_PROFILE}" ]]; then
    log_remove "${ENV_PROFILE}..."
    rm -f "${ENV_PROFILE}"
    log_ok "Fichero de entorno eliminado: ${ENV_PROFILE}"
else
    log_ok "No existia: ${ENV_PROFILE}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 4/6 — Desinstalar CMake y Ninja via apt
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 4/6] Desinstalando CMake y Ninja..."

for pkg in cmake ninja-build; do
    if dpkg -s "${pkg}" &>/dev/null; then
        log_remove "${pkg}..."
        apt-get remove -y "${pkg}"
        log_ok "${pkg} desinstalado"
    else
        log_ok "${pkg} no estaba instalado via apt"
    fi
done

# ─────────────────────────────────────────────────────────────────────────────
# PASO 5/6 — Desinstalar extensiones de VS Code
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 5/6] Desinstalando extensiones de VS Code..."

EXTENSIONS=(
    "Arm.keil-studio-pack"
    "ms-vscode.cpptools"
    "ms-vscode.cmake-tools"
)

if command -v code &>/dev/null; then
    for ext in "${EXTENSIONS[@]}"; do
        log_info "Desinstalando extension ${ext}..."
        # Las extensiones pertenecen al usuario real, no a root
        if sudo -u "${REAL_USER}" code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
            sudo -u "${REAL_USER}" code --uninstall-extension "${ext}" --force 2>/dev/null || true
            log_ok "Extension desinstalada: ${ext}"
        else
            log_ok "Extension no estaba instalada: ${ext}"
        fi
    done
else
    log_warn "VS Code (code) no encontrado en PATH, omitiendo extensiones."
fi

# ─────────────────────────────────────────────────────────────────────────────
# PASO 6/6 — VS Code (opcional)
# ─────────────────────────────────────────────────────────────────────────────
log_step "[PASO 6/6] Visual Studio Code..."

if ask_yes_no "Desinstalar tambien Visual Studio Code?"; then
    if dpkg -s code &>/dev/null; then
        log_remove "Visual Studio Code..."
        apt-get remove -y code
        log_ok "VS Code desinstalado"
    else
        log_ok "VS Code no estaba instalado via apt"
    fi

    # Eliminar repositorio y clave Microsoft
    if ask_yes_no "Eliminar tambien el repositorio apt de Microsoft?"; then
        rm -f /etc/apt/sources.list.d/vscode.list
        rm -f /usr/share/keyrings/microsoft.gpg
        apt-get update -qq
        log_ok "Repositorio Microsoft eliminado"
    fi
else
    log_ok "Visual Studio Code conservado"
fi

# Detectar nombre real del paquete
STLINK_PKG=$(dpkg -l | grep -i stlink | awk '{print $2}' | head -1)

if [[ -n "${STLINK_PKG}" ]]; then
    log_info "Desinstalando ${STLINK_PKG}..."
    apt-get remove --purge -y "${STLINK_PKG}"
    apt-get autoremove -y
    log_ok "${STLINK_PKG} desinstalado"
else
    log_ok "stlink no estaba instalado"
fi
# ─────────────────────────────────────────────────────────────────────────────
# FIN
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${GREEN}${BOLD}   Desinstalacion completada                 ${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
echo -e "${YELLOW}  Cierra y vuelve a abrir la terminal para${NC}"
echo -e "${YELLOW}  que los cambios en PATH tomen efecto.${NC}"
echo -e "${GREEN}${BOLD}=============================================${NC}"
