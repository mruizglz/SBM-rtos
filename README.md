<img width="827" height="443" alt="SFS53958" src="https://github.com/user-attachments/assets/7a810d83-c033-4eeb-9b89-aa328cc0d363" />
# Sistemas Basados en Microprocesador (ETSI Sistemas de Telecomunicación-Campus Sur UPM)

Repositorio con información sobre la asignatura Sistemas Basados en Microprocesador de la ETSIS Telecomunicación de la UPM. 

## Estructura del repositorio

- `B2/` - Ejemplos de uso de CMSIS-RTOS v2 (proyectos en Keil µVision y Visual Studio Code) y material de la presentación de CMSIS-RTOS2.
  - `ejemplothreads/`, `ejemplothreads-flags/`, `ejemplothreads-queues/`, `ejemplothreads-timers/` - Código fuente (`src/`), proyecto Keil (`keil/`) y proyecto de Visual Code/CMSIS (`vc/`) de cada ejemplo.
  - `presentation/` - Diapositivas y material gráfico (en español e inglés) utilizados en las sesiones teóricas.
- `docs/` - Fuentes en reStructuredText (Sphinx) de la documentación de ayuda publicada en GitHub Pages.
- `vc-install/` - Scripts de instalación/desinstalación de Visual Studio Code y del soporte CMSIS para Windows y Linux.

## Máquina Virtual con Ubuntu 24.04, Visual Code y CMSIS Extension instalados

En este enlace se puede descargar la [máquina virtual](https://upm365-my.sharepoint.com/:u:/g/personal/mariano_ruiz_upm_es/IQCnubkelH05QY98gCN30LEDAX24d1cmgmsMIaeRfQpLmm4?e=k6EpNH)
usuario: sbm
password: sbm.2026

Una vez realizado el login, abra un terminal y ejecute los siguientes comandos:

```console
source /etc/profile.d/sbm-rtos.sh
code
```

## Instalación de las herramientas para Visual Code

La carpeta `vc-install` contiene los scripts para instalar Visual Code en Windows y Linux, así como el soporte para usar CMSIS.
La asignatura continúa usando oficialmente Keil µVision, pero, dado que ARM dejará de actualizar esas herramientas y migrará a VC, se ofrece la opción de comenzar a utilizarlo.


- `vc-install/windows/installer2.ps1` y `vc-install/windows/uninstaller.ps1` - Instalación y desinstalación completas del entorno en Windows.
- `vc-install/linux/install.sh` y `vc-install/linux/uninstall.sh` - Instalación y desinstalación completas del entorno en Linux (Ubuntu 24.04).

## Documentación

La documentación de ayuda (generada a partir de las fuentes en `docs/`) está disponible en:

- Sphinx Doc: https://univ-politecnica-madrid.github.io/SBM/
- PDF: https://univ-politecnica-madrid.github.io/SBM/simplepdf/SBM-CMSIS-RTOS-V2.pdf

