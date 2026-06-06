.. _vscode:

=========================================
Entorno Visual Studio Code para SBM-RTOS
=========================================

Esta guía documenta la instalación del entorno de trabajo a partir de los
scripts incluidos en ``/tmp/workspace/mruizglz/SBM-rtos/vc-install``. El
objetivo es dejar una máquina preparada para abrir, compilar y depurar los
ejemplos del repositorio con Visual Studio Code y el ecosistema CMSIS.

Los scripts disponibles son:

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Script
     - Propósito
   * - ``vc-install/linux/install.sh``
     - Instalación completa del entorno en Linux
   * - ``vc-install/linux/uninstall.sh``
     - Desinstalación del entorno en Linux
   * - ``vc-install/windows/installer2.ps1``
     - Instalación completa del entorno en Windows
   * - ``vc-install/windows/uninstaller.ps1``
     - Desinstalación del entorno en Windows

Qué instala el entorno
======================

Ambos instaladores persiguen la misma idea: centralizar las herramientas y los
packs CMSIS en una ubicación compartida de sistema y dejar VS Code listo para
trabajar con proyectos ARM/CMSIS.

Componentes principales
-----------------------

.. list-table::
   :header-rows: 1
   :widths: 35 25 40

   * - Componente
     - Versión / identificador
     - Notas
   * - CMSIS-Toolbox
     - Linux ``2.14.1`` / Windows ``2.13.0``
     - Aporta ``cbuild`` y ``cpackget``
   * - Arm Compiler 6
     - ``6.24`` build ``19``
     - Se expone mediante ``AC6_TOOLCHAIN_6_24_0``
   * - CMake
     - Versión disponible en el gestor del sistema
     - Dependencia de ``cbuild``
   * - Ninja
     - Versión disponible en el gestor del sistema
     - Generador usado por CMake
   * - Visual Studio Code
     - Última disponible en el gestor del sistema
     - Editor principal
   * - Extensión ARM
     - ``Arm.keil-studio-pack``
     - Pack de extensiones para CMSIS/ARM
   * - Extensión C/C++
     - ``ms-vscode.cpptools``
     - IntelliSense y soporte C/C++
   * - Extensión CMake
     - ``ms-vscode.cmake-tools``
     - Integración de CMake en VS Code
   * - Extensión de depuración Cortex-M
     - ``marus25.cortex-debug``
     - Instalada por ambos scripts

Packs CMSIS instalados
----------------------

.. list-table::
   :header-rows: 1
   :widths: 35 20 45

   * - Pack
     - Versión
     - Uso
   * - ``ARM::CMSIS``
     - ``6.3.0``
     - Núcleo CMSIS y cabeceras base
   * - ``Keil::STM32F4xx_DFP``
     - ``2.17.1``
     - Soporte de dispositivos STM32F4
   * - ``ARM::CMSIS-Driver``
     - ``2.10.0``
     - Drivers CMSIS
   * - ``ARM::CMSIS-RTX``
     - ``5.9.1``
     - Implementación RTX5 / CMSIS-RTOS2
   * - ``Keil::MDK-Middleware``
     - ``8.1.0``
     - Middleware Keil

.. note::

   Los instaladores no compilan el repositorio. Su función es preparar el
   entorno de herramientas, variables, extensiones y paquetes.


Linux
=====

El instalador Linux está pensado para Ubuntu LTS de 64 bits y debe ejecutarse
como ``root``.

Sistema objetivo
----------------

Según el encabezado del script, el flujo ha sido probado en:

* ``Ubuntu 22.04 LTS``
* ``Ubuntu 24.04 LTS``
* Arquitectura ``x86_64``

Requisitos previos
------------------

Antes de lanzar el script, verifica:

* Acceso a Internet para descargar herramientas, paquetes CMSIS y VS Code.
* Usuario con privilegios ``sudo``.
* Que el usuario final tenga una ``home`` válida, ya que el instalador modifica
  ``~/.bashrc`` y ``~/.config/Code/User/settings.json`` del usuario que invoca
  ``sudo``.
* Espacio en disco suficiente en ``/opt/ARM-Shared``.

Archivos implicados
-------------------

* Instalador: ``/tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/install.sh``
* Desinstalador: ``/tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/uninstall.sh``

Cómo ejecutar la instalación
----------------------------

Desde la raíz del repositorio:

.. code-block:: bash

   cd /tmp/workspace/mruizglz/SBM-rtos
   sudo bash /tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/install.sh

Qué hace el script paso a paso
------------------------------

El script implementa diez pasos principales:

1. **Crea la estructura base** en ``/opt/ARM-Shared``:

   * ``/opt/ARM-Shared/Packs``
   * ``/opt/ARM-Shared/downloads``

2. **Define ``CMSIS_PACK_ROOT``** en el fichero global:

   .. code-block:: text

      /etc/profile.d/sbm-rtos.sh

3. **Aplica permisos** sobre ``/opt/ARM-Shared/Packs``.
4. **Descarga y extrae CMSIS-Toolbox** en:

   .. code-block:: text

      /opt/ARM-Shared/cmsis-toolbox-linux-amd64

5. **Instala CMake** con ``apt`` si no está disponible.
6. **Instala Ninja** con ``apt`` si no está disponible.
7. **Descarga e instala Arm Compiler 6** en:

   .. code-block:: text

      /opt/ARM-Shared/ArmCompilerforEmbedded

   y publica la variable:

   .. code-block:: text

      AC6_TOOLCHAIN_6_24_0

8. **Inicializa ``cpackget``** con el índice público:

   .. code-block:: text

      https://www.keil.com/pack/index.pidx

9. **Instala los packs CMSIS** listados en la sección anterior.
10. **Instala Visual Studio Code y extensiones**, y además escribe
    configuración global de VS Code para el usuario real.

Variables y rutas configuradas
------------------------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Elemento
     - Valor
   * - ``CMSIS_PACK_ROOT``
     - ``/opt/ARM-Shared/Packs``
   * - ``AC6_TOOLCHAIN_6_24_0``
     - ``/opt/ARM-Shared/ArmCompilerforEmbedded/bin`` o el ``bin`` real detectado
   * - Perfil global
     - ``/etc/profile.d/sbm-rtos.sh``
   * - Toolbox
     - ``/opt/ARM-Shared/cmsis-toolbox-linux-amd64/bin``
   * - Compilador AC6
     - ``/opt/ARM-Shared/ArmCompilerforEmbedded/bin``
   * - Descargas
     - ``/opt/ARM-Shared/downloads``

Para evitar que el terminal integrado de VS Code ignore las variables cargadas
en ``/etc/profile.d``, el instalador añade un bloque a ``~/.bashrc`` del
usuario invocador y genera ``~/.config/Code/User/settings.json``.

Configuración global de VS Code que genera el script
----------------------------------------------------

En Linux, el script modifica el fichero:

.. code-block:: text

   ~/.config/Code/User/settings.json

Las claves que se escriben son:

.. code-block:: json

   {
       "terminal.integrated.env.linux": {
           "CMSIS_PACK_ROOT": "/opt/ARM-Shared/Packs",
           "AC6_TOOLCHAIN_6_24_0": "/opt/ARM-Shared/ArmCompilerforEmbedded/bin",
           "PATH": "/opt/ARM-Shared/ArmCompilerforEmbedded/bin:/opt/ARM-Shared/cmsis-toolbox-linux-amd64/bin:${env:PATH}"
       },
       "cmake.environment": {
           "CMSIS_PACK_ROOT": "/opt/ARM-Shared/Packs",
           "AC6_TOOLCHAIN_6_24_0": "/opt/ARM-Shared/ArmCompilerforEmbedded/bin"
       },
       "vcpkg.enabled": false,
       "arm-tools.autoActivate": false,
       "debug.hideSlowPreLaunchWarning": true
   }

.. important::

   En Linux el instalador también descarga e instala ``stlink`` desde un
   paquete ``.deb`` de GitHub Releases. Ese paso no existe en el instalador de
   Windows.

Verificación posterior
----------------------

Después de instalar, cierra la sesión o ejecuta:

.. code-block:: bash

   source /etc/profile.d/sbm-rtos.sh
   source ~/.bashrc

Comprueba el entorno:

.. code-block:: bash

   echo "$CMSIS_PACK_ROOT"
   which cpackget
   cbuild --version
   cpackget list
   code --list-extensions | grep -E 'Arm.keil-studio-pack|ms-vscode.cpptools|ms-vscode.cmake-tools|marus25.cortex-debug'

Resultado esperado:

* ``CMSIS_PACK_ROOT`` debe apuntar a ``/opt/ARM-Shared/Packs``.
* ``cpackget`` debe resolverse desde el directorio de CMSIS-Toolbox.
* ``cpackget list`` debe mostrar los cinco packs instalados.
* El listado de extensiones debe incluir las cuatro extensiones configuradas por
  el script.

Incidencias típicas
-------------------

* **``cpackget`` no aparece en PATH**: abre una terminal nueva o ejecuta
  ``source /etc/profile.d/sbm-rtos.sh``.
* **VS Code no ve las variables**: cierra y vuelve a abrir VS Code; el script
  prepara ``settings.json`` y ``.bashrc``, pero una sesión ya abierta no relee
  esas variables.
* **Descargas repetidas**: el script evita redescargar ficheros ya presentes en
  ``/opt/ARM-Shared/downloads``.
* **Packs con licencia embebida**: el instalador Linux ejecuta ``cpackget add``
  con ``--agree-embedded-license`` para evitar preguntas interactivas.

Desinstalación en Linux
-----------------------

Para revertir la instalación:

.. code-block:: bash

   cd /tmp/workspace/mruizglz/SBM-rtos
   sudo bash /tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/uninstall.sh

El desinstalador:

* Elimina los packs CMSIS instalados.
* Borra ``/opt/ARM-Shared``.
* Elimina ``/etc/profile.d/sbm-rtos.sh``.
* Desinstala ``cmake`` y ``ninja-build`` si fueron instalados por ``apt``.
* Desinstala las extensiones de VS Code.
* Ofrece opcionalmente desinstalar VS Code y su repositorio ``apt``.
* Intenta purgar el paquete ``stlink`` detectado en el sistema.


Windows
=======

El instalador Windows está escrito en PowerShell y debe ejecutarse como
Administrador.

Sistema objetivo
----------------

El script no fija una versión concreta de Windows, pero por las herramientas
utilizadas requiere un entorno con:

* PowerShell
* ``winget``
* permisos de Administrador
* acceso a Internet

Además, el instalador asume la existencia de:

.. code-block:: text

   C:\Program Files\7-Zip\7z.exe

Ese ejecutable se usa para descomprimir Arm Compiler 6.

Archivos implicados
-------------------

* Instalador: ``/tmp/workspace/mruizglz/SBM-rtos/vc-install/windows/installer2.ps1``
* Desinstalador: ``/tmp/workspace/mruizglz/SBM-rtos/vc-install/windows/uninstaller.ps1``

Cómo ejecutar la instalación
----------------------------

Abre **PowerShell como Administrador** y ejecuta:

.. code-block:: powershell

   Set-ExecutionPolicy -Scope Process Bypass -Force
   cd C:\ruta\al\repositorio\SBM-rtos
   .\vc-install\windows\installer2.ps1

Si quieres ejecutarlo usando la ruta absoluta del clon de trabajo:

.. code-block:: powershell

   Set-ExecutionPolicy -Scope Process Bypass -Force
   & "C:\ruta\al\repositorio\SBM-rtos\vc-install\windows\installer2.ps1"

Qué hace el script paso a paso
------------------------------

El flujo Windows también se divide en diez pasos:

1. **Crea carpetas base**:

   * ``C:\ARM-Shared\Packs``
   * ``C:\ARM-Shared\downloads``

2. **Define la variable de sistema**:

   .. code-block:: text

      CMSIS_PACK_ROOT=C:\ARM-Shared\Packs

3. **Configura permisos** en ``C:\ARM-Shared\Packs`` con ``icacls``.
4. **Descarga y extrae CMSIS-Toolbox** en:

   .. code-block:: text

      C:\ARM-Shared\cmsis-toolbox-windows-amd64

5. **Instala CMake** mediante ``winget``.
6. **Instala Ninja** mediante ``winget``.
7. **Descarga y extrae Arm Compiler 6** en:

   .. code-block:: text

      C:\ARM-Shared\ArmCompilerforEmbedded

   y define:

   .. code-block:: text

      AC6_TOOLCHAIN_6_24_0

8. **Inicializa ``cpackget``** con el índice público.
9. **Instala los packs CMSIS** necesarios.
10. **Instala Visual Studio Code y extensiones**.

Herramientas instaladas con winget
----------------------------------

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Id de ``winget``
     - Componente
   * - ``Kitware.CMake``
     - CMake
   * - ``Ninja-build.Ninja``
     - Ninja
   * - ``Microsoft.VisualStudioCode``
     - Visual Studio Code

Variables y rutas configuradas
------------------------------

.. list-table::
   :header-rows: 1
   :widths: 35 65

   * - Elemento
     - Valor
   * - ``CMSIS_PACK_ROOT``
     - ``C:\ARM-Shared\Packs``
   * - ``AC6_TOOLCHAIN_6_24_0``
     - ``C:\ARM-Shared\ArmCompilerforEmbedded\bin``
   * - Toolbox
     - ``C:\ARM-Shared\cmsis-toolbox-windows-amd64\bin``
   * - Descargas
     - ``C:\ARM-Shared\downloads``

El script también añade al ``PATH`` de máquina:

* ``C:\ARM-Shared\cmsis-toolbox-windows-amd64\bin``
* ``C:\ARM-Shared\ArmCompilerforEmbedded\bin``

Extensiones instaladas en VS Code
---------------------------------

El instalador Windows ejecuta:

.. code-block:: powershell

   code --install-extension Arm.keil-studio-pack --force
   code --install-extension ms-vscode.cpptools --force
   code --install-extension ms-vscode.cmake-tools --force
   code --install-extension marus25.cortex-debug --force

.. note::

   A diferencia del instalador Linux, el script de Windows no escribe un
   ``settings.json`` global para VS Code. Configura herramientas, PATH,
   variables de entorno y extensiones, pero no añade ajustes adicionales de
   editor o CMake.

Verificación posterior
----------------------

Abre una **nueva** consola PowerShell y ejecuta:

.. code-block:: powershell

   echo $env:CMSIS_PACK_ROOT
   Get-Command cpackget
   cbuild --version
   cpackget list
   code --list-extensions | Select-String "Arm.keil-studio-pack|ms-vscode.cpptools|ms-vscode.cmake-tools|marus25.cortex-debug"

Resultado esperado:

* ``CMSIS_PACK_ROOT`` debe ser ``C:\ARM-Shared\Packs``.
* ``Get-Command cpackget`` debe resolver el ejecutable del toolbox.
* ``cpackget list`` debe listar los cinco packs instalados por el script.
* VS Code debe mostrar las cuatro extensiones requeridas.

Incidencias típicas
-------------------

* **``winget`` no está disponible**: actualiza *App Installer* o ejecuta el
  script en una versión de Windows que ya lo incluya.
* **Falta 7-Zip**: el script usa ``C:\Program Files\7-Zip\7z.exe`` para extraer
  Arm Compiler 6; si no existe, la instalación fallará.
* **``code`` no aparece en PATH**: el script intenta localizar ``code.cmd`` en
  rutas conocidas de VS Code y añadirlo a la sesión actual, pero para usos
  futuros conviene abrir una consola nueva.
* **Variables no visibles en una consola antigua**: reinicia PowerShell o el
  equipo para recargar PATH y variables de entorno de máquina.

Desinstalación en Windows
-------------------------

Abre **PowerShell como Administrador** y ejecuta:

.. code-block:: powershell

   Set-ExecutionPolicy -Scope Process Bypass -Force
   cd C:\ruta\al\repositorio\SBM-rtos
   .\vc-install\windows\uninstaller.ps1

El desinstalador:

* Elimina ``C:\ARM-Shared``.
* Borra ``CMSIS_PACK_ROOT``.
* Limpia el ``PATH`` de máquina del toolbox.
* Desinstala ``Ninja`` y ``CMake`` mediante ``winget``.
* Desinstala las extensiones de VS Code.
* Pregunta opcionalmente si también debe desinstalar Visual Studio Code.


Recomendaciones de uso
======================

1. Ejecuta los instaladores siempre con privilegios de administrador.
2. Mantén ``CMSIS_PACK_ROOT`` en una ruta compartida y estable.
3. Abre una consola nueva tras la instalación antes de validar comandos.
4. Si trabajas en laboratorios o equipos compartidos, evita mover
   manualmente ``/opt/ARM-Shared`` o ``C:\ARM-Shared`` después de instalar.
5. Si necesitas rehacer la instalación, usa primero el desinstalador del mismo
   sistema operativo.

Resumen rápido
==============

.. list-table::
   :header-rows: 1
   :widths: 20 40 40

   * - Sistema
     - Instalación
     - Desinstalación
   * - Linux
     - ``sudo bash /tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/install.sh``
     - ``sudo bash /tmp/workspace/mruizglz/SBM-rtos/vc-install/linux/uninstall.sh``
   * - Windows
     - ``.\vc-install\windows\installer2.ps1``
     - ``.\vc-install\windows\uninstaller.ps1``
