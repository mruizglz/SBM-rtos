.. _vscode:

================================
Instalación de Visual Studio Code
================================

Descarga
========

1. Abre el navegador y ve a https://code.visualstudio.com/download
2. Haz clic en el botón **Windows** (descarga el instalador ``.exe`` de 64 bits).

.. tip::

   Descarga el instalador de **sistema** (*System Installer*) en lugar del
   de usuario si quieres que VS Code quede disponible para todos los usuarios
   de la máquina:
   ``VSCodeSetup-x64-<version>.exe``

Instalación
===========

1. Ejecuta el instalador descargado (doble clic).
2. Acepta el acuerdo de licencia.
3. En la pantalla **Seleccionar tareas adicionales**, marca **todas** las opciones:

   * Agregar acción «Abrir con Code» al menú contextual de archivos.
   * Agregar acción «Abrir con Code» al menú contextual de directorios.
   * Registrar Code como editor predeterminado para los tipos de archivo compatibles.
   * **Agregar a PATH** *(imprescindible)*.

4. Haz clic en **Instalar** y espera a que finalice.
5. Haz clic en **Finalizar** con la opción *Iniciar Visual Studio Code* marcada.

Verificación
============

Abre un terminal (``Win + R`` → ``cmd``) y ejecuta:

.. code-block:: powershell

   code --version

Deberías ver una salida similar a:

.. code-block:: text

   1.89.1
   b58957e67ee1e712cebf466b995adf4c5307b2bd
   x64

.. note::

   Si el comando ``code`` no se reconoce, cierra y vuelve a abrir el terminal
   para que recoja la actualización del PATH realizada por el instalador.

Configuración recomendada del editor
=====================================

Abre VS Code y accede a la configuración con :kbd:`Ctrl+,`.
Busca y ajusta los siguientes parámetros:

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Parámetro
     - Valor recomendado
   * - ``editor.formatOnSave``
     - ``true``
   * - ``editor.tabSize``
     - ``4``
   * - ``files.encoding``
     - ``utf8``
   * - ``files.eol``
     - ``\\n`` (LF)
   * - ``terminal.integrated.defaultProfile.windows``
     - ``PowerShell``

.. _extension:

====================================
Instalación de ARM Keil Studio Pack
====================================

La extensión **ARM Keil Studio Pack** (MDK v6) agrupa todas las extensiones
necesarias para desarrollo embebido ARM en un único paquete que se instala
con un solo clic.

Extensiones incluidas en el pack
=================================

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Extensión
     - Función
   * - Arm CMSIS Solution
     - Gestión de proyectos ``.csolution.yml``
   * - Arm Device Manager
     - Detección y gestión de placas conectadas
   * - Arm Tools Environment Manager
     - Gestión de toolchain vía vcpkg
   * - Arm Embedded Debugger
     - Depuración con GDB / CMSIS-DAP
   * - Arm Virtual Hardware
     - Simulación con modelos FVP (Corstone)
   * - Microsoft C/C++
     - IntelliSense y resaltado de sintaxis

Instalación paso a paso
========================

**Desde el Marketplace de VS Code:**

1. Abre VS Code.
2. Pulsa :kbd:`Ctrl+Shift+X` para abrir el panel de extensiones.
3. En el campo de búsqueda escribe:

   .. code-block:: text

      Keil Studio Pack

4. Selecciona la extensión publicada por **Arm**.
5. Haz clic en **Install**.

   La instalación descarga e instala automáticamente todas las extensiones
   del pack. Puede tardar 1-2 minutos.

6. Cuando aparezca el botón **Reload Required**, haz clic en él para
   reiniciar VS Code.

**Alternativa — instalación desde línea de comandos:**

.. code-block:: powershell

   code --install-extension Arm.keil-studio-pack

Verificación de la instalación
================================

1. Pulsa :kbd:`Ctrl+Shift+X`.
2. Filtra por ``@installed Keil``.
3. Debes ver las extensiones listadas en la tabla anterior con estado **Enabled**.

También puedes verificarlo desde el terminal:

.. code-block:: powershell

   code --list-extensions | findstr -i arm

Salida esperada:

.. code-block:: text

   Arm.cmsis-csolution
   Arm.device-manager
   Arm.embedded-debug
   Arm.keil-studio-pack
   Arm.tool-manager

Activación de licencia (si aplica)
====================================

Las herramientas de código abierto (Arm GNU Toolchain, CMSIS-Toolbox,
Arm CMSIS Debugger) **no requieren licencia**.

Si usas el compilador comercial **Arm Compiler 6 (AC6)**, necesitas
una licencia UBL (User-Based License):

1. Pulsa :kbd:`Ctrl+Shift+P`.
2. Escribe ``Arm: Activate or manage Arm licenses``.
3. Introduce tu código de activación o dirección del servidor UBL.

.. note::

   Para proyectos con GCC (``arm-none-eabi-gcc``) no se necesita ninguna
   licencia. Esta guía usa GCC por defecto.

   .. _entorno:

====================================
Variable de entorno CMSIS_PACK_ROOT
====================================

``CMSIS_PACK_ROOT`` define la carpeta donde se almacenan todos los paquetes
CMSIS descargados (``.pack``). Configurarla correctamente permite:

* Compartir los paquetes entre todos los usuarios de la máquina.
* Evitar descargas duplicadas.
* Apuntar a una unidad de red en entornos corporativos.

Valor por defecto
=================

Si no se define ``CMSIS_PACK_ROOT``, el toolbox usa la ruta por defecto de
cada usuario:

.. code-block:: text

   %LOCALAPPDATA%\Arm\Packs
   (equivale a: C:\Users\<nombre_usuario>\AppData\Local\Arm\Packs)

Este comportamiento hace que **cada usuario descargue sus propios paquetes**,
lo que consume espacio innecesario en máquinas compartidas.

Configuración de la variable (Administrador)
============================================

El siguiente procedimiento define ``CMSIS_PACK_ROOT`` a nivel de **sistema**,
de modo que aplica a todos los usuarios.

Paso 1 — Crear la carpeta compartida
-------------------------------------

.. code-block:: powershell

   # Ejecutar como Administrador
   New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\Packs"

Paso 2 — Definir la variable de sistema
-----------------------------------------

.. code-block:: powershell

   # Ejecutar como Administrador
   [System.Environment]::SetEnvironmentVariable(
       "CMSIS_PACK_ROOT",
       "C:\ARM-Shared\Packs",
       "Machine"
   )

.. warning::

   El parámetro ``"Machine"`` aplica la variable a **todo el sistema**.
   Usa ``"User"`` si solo quieres afectar al usuario actual.

Paso 3 — Establecer permisos de carpeta
-----------------------------------------

Otorga permisos de **lectura** a todos los usuarios y **escritura** solo
a los administradores:

.. code-block:: powershell

   # Ejecutar como Administrador
   icacls "C:\ARM-Shared\Packs" /grant "Users:(OI)(CI)R"  /T
   icacls "C:\ARM-Shared\Packs" /grant "Administrators:(OI)(CI)F" /T

Verificación en VS Code
========================

Abre el terminal integrado de VS Code (:kbd:`Ctrl+`` `) y ejecuta:

.. code-block:: powershell

   # PowerShell
   echo $env:CMSIS_PACK_ROOT

   # CMD
   echo %CMSIS_PACK_ROOT%

La salida debe mostrar exactamente:

.. code-block:: text

   C:\ARM-Shared\Packs

Para ver todas las variables de entorno relacionadas con ARM:

.. code-block:: powershell

   Get-ChildItem Env: | Where-Object {
       $_.Name -like "*CMSIS*" -or
       $_.Name -like "*ARM*"  -or
       $_.Name -like "*VCPKG*"
   }

.. important::

   Si la variable se definió mientras VS Code estaba abierto, **cierra y
   vuelve a abrir VS Code** para que recoja el nuevo valor. No basta con
   abrir un terminal nuevo dentro de VS Code.

Estructura de la carpeta de paquetes
======================================

Una vez inicializada, la carpeta ``CMSIS_PACK_ROOT`` tendrá esta estructura:

.. code-block:: text

   C:\ARM-Shared\Packs\
   ├── .Download\          ← archivos .pack descargados (caché)
   ├── .Local\             ← paquetes locales / privados
   ├── .Web\
   │   └── index.pidx     ← índice público de paquetes disponibles
   ├── ARM\
   │   └── CMSIS\
   │       └── 6.x.x\     ← pack descomprimido
   └── Keil\
       └── STM32F4xx_DFP\
           └── 2.x.x\


.. _paquetes:

=========================
Descarga de paquetes CMSIS
=========================

Inicialización del repositorio de paquetes
==========================================

Antes de instalar cualquier paquete hay que inicializar la carpeta
``CMSIS_PACK_ROOT`` con el índice público. Ejecuta el siguiente comando
**una sola vez** desde el terminal de VS Code (como Administrador si usas
ruta compartida):

.. code-block:: powershell

   cpackget init https://www.keil.com/pack/index.pidx

Este comando descarga el índice de todos los paquetes públicos disponibles
(``index.pidx``) y lo almacena en ``CMSIS_PACK_ROOT\.Web\``.

Paquetes necesarios para STM32F429
====================================

Instala los siguientes paquetes en orden:

Paquete 1 — CMSIS Core
------------------------

Proporciona los headers del núcleo Cortex-M (``core_cm4.h``,
``cmsis_gcc.h``, etc.):

.. code-block:: powershell

   cpackget add ARM::CMSIS@6.1.0

Paquete 2 — Device Family Pack (DFP) de STM32F4
-------------------------------------------------

Proporciona soporte completo para todos los dispositivos de la familia
STM32F4: archivos de startup, linker scripts, headers de periféricos y
algoritmos de flash:

.. code-block:: powershell

   cpackget add Keil::STM32F4xx_DFP@2.17.1

.. note::

   Para instalar siempre la versión más reciente disponible, omite el
   número de versión:

   .. code-block:: powershell

      cpackget add Keil::STM32F4xx_DFP

Paquete 3 — CMSIS-RTX (FreeRTOS / RTX5) — opcional
-----------------------------------------------------

Necesario si usas el RTOS RTX5 de Keil:

.. code-block:: powershell

   cpackget add ARM::CMSIS-RTX@5.9.0

Paquete 4 — MDK Middleware — opcional
--------------------------------------

Proporciona pilas USB, TCP/IP y sistema de ficheros:

.. code-block:: powershell

   cpackget add Keil::MDK-Middleware@8.0.0

Paquete 5 — CMSIS-Compiler — recomendado
-----------------------------------------

Abstracción del compilador para redirección de ``printf`` por UART/ITM:

.. code-block:: powershell

   cpackget add ARM::CMSIS-Compiler@2.0.0

Instalación en bloque
======================

Puedes instalar todos los paquetes necesarios de una vez copiando el
bloque completo:

.. code-block:: powershell

   cpackget add ARM::CMSIS@6.1.0
   cpackget add Keil::STM32F4xx_DFP@2.17.1
   cpackget add ARM::CMSIS-RTX@5.9.0
   cpackget add ARM::CMSIS-Compiler@2.0.0

Verificación de paquetes instalados
=====================================

Lista todos los paquetes instalados actualmente:

.. code-block:: powershell

   cpackget list

Salida esperada:

.. code-block:: text

   i ARM::CMSIS@6.1.0
   i ARM::CMSIS-Compiler@2.0.0
   i ARM::CMSIS-RTX@5.9.0
   i Keil::STM32F4xx_DFP@2.17.1

El prefijo ``i`` indica que el paquete está instalado correctamente.

Actualización del índice de paquetes
=====================================

Para obtener las versiones más recientes disponibles en el repositorio
público, actualiza el índice periódicamente:

.. code-block:: powershell

   cpackget update-index

Desinstalación de un paquete
==============================

.. code-block:: powershell

   cpackget rm Keil::STM32F4xx_DFP@2.17.1

Resumen de paquetes
====================

.. list-table::
   :header-rows: 1
   :widths: 35 20 15 30

   * - Paquete
     - Versión
     - Obligatorio
     - Contenido principal
   * - ``ARM::CMSIS``
     - 6.1.0
     - Sí
     - Headers Cortex-M4, CMSIS-Core
   * - ``Keil::STM32F4xx_DFP``
     - 2.17.1
     - Sí
     - Startup, linker, headers STM32F4
   * - ``ARM::CMSIS-RTX``
     - 5.9.0
     - Si usas RTOS
     - RTX5 / CMSIS-RTOS2
   * - ``ARM::CMSIS-Compiler``
     - 2.0.0
     - Recomendado
     - Redirección de stdio (ITM/UART)
   * - ``Keil::MDK-Middleware``
     - 8.0.0
     - Opcional
     - USB, TCP/IP, FileSystem

.. _verificacion:

========================
Verificación del entorno
========================

Lista de verificación completa
================================

Ejecuta cada comando desde el **terminal integrado de VS Code** y comprueba
que la salida coincide con la esperada.

Paso 1 — Variable de entorno
------------------------------

.. code-block:: powershell

   echo $env:CMSIS_PACK_ROOT

Salida esperada:

.. code-block:: text

   C:\ARM-Shared\Packs

Paso 2 — CMSIS-Toolbox
------------------------

.. code-block:: powershell

   cbuild --version

Salida esperada (versión puede variar):

.. code-block:: text

   cbuild: Build Invocation 2.7.0 (C) 2022-2026 Arm Ltd.

Paso 3 — Gestor de paquetes
-----------------------------

.. code-block:: powershell

   cpackget list

Salida esperada:

.. code-block:: text

   i ARM::CMSIS@6.1.0
   i ARM::CMSIS-Compiler@2.0.0
   i ARM::CMSIS-RTX@5.9.0
   i Keil::STM32F4xx_DFP@2.17.1

Paso 4 — Compilador GCC
-------------------------

.. code-block:: powershell

   arm-none-eabi-gcc --version

Salida esperada:

.. code-block:: text

   arm-none-eabi-gcc (Arm GNU Toolchain 13.x) 13.x.x
   Copyright (C) 2023 Free Software Foundation, Inc.

Paso 5 — Entorno completo
---------------------------

.. code-block:: powershell

   cbuild list environment

Salida esperada:

.. code-block:: text

   CMSIS-Toolbox version: 2.7.0
   CMake: 3.31.5
   Ninja: 1.12.0

Crear y compilar un proyecto de prueba
=======================================

El método más fiable para verificar la instalación completa es crear un
proyecto mínimo y compilarlo.

1. Crea una carpeta de prueba:

   .. code-block:: powershell

      mkdir C:\test-stm32 ; cd C:\test-stm32

2. Desde VS Code: :kbd:`Ctrl+Shift+P` → ``CMSIS: Create a new solution``.
3. Selecciona:

   * **Device:** ``STM32F429ZITx``
   * **Compiler:** ``GCC``
   * **Template:** ``Blinky``

4. Pulsa el botón **Build** (martillo) en la vista CMSIS.

5. Resultado esperado en el terminal:

   .. code-block:: text

      Building CMake target 'Blinky+Target_1'
      Using compiler: GCC xx.x.x
      [x/x] Linking C executable Blinky.axf
      Program Size: Code=xxxx  RO-data=xxx  RW-data=xx  ZI-data=xxxxx
      ✅ Completed: cbuild succeed with exit code 0

.. important::

   Si la compilación falla con errores de paquetes no encontrados, ejecuta:

   .. code-block:: powershell

      cbuild Blinky.csolution.yml --packs

   El flag ``--packs`` fuerza la descarga de cualquier paquete faltante.

Tabla resumen de verificación
================================

.. list-table::
   :header-rows: 1
   :widths: 40 30 30

   * - Verificación
     - Comando
     - Resultado esperado
   * - Variable CMSIS_PACK_ROOT
     - ``echo $env:CMSIS_PACK_ROOT``
     - ``C:\ARM-Shared\Packs``
   * - CMSIS-Toolbox
     - ``cbuild --version``
     - ``2.x.x``
   * - Paquetes instalados
     - ``cpackget list``
     - Lista con prefijo ``i``
   * - Compilador GCC
     - ``arm-none-eabi-gcc --version``
     - ``13.x.x``
   * - Build de prueba
     - Botón Build en VS Code
     - ``exit code 0``

     .. _multiusuario:

=========================
Configuración multiusuario
=========================

Esta sección describe cómo compartir los paquetes y herramientas entre
varios usuarios de la misma máquina Windows, evitando descargas duplicadas.

Qué se puede compartir
=======================

.. list-table::
   :header-rows: 1
   :widths: 30 15 55

   * - Componente
     - Compartible
     - Notas
   * - Paquetes CMSIS (``.pack``)
     - ✅ Sí
     - Via ``CMSIS_PACK_ROOT`` apuntando a carpeta compartida
   * - CMSIS-Toolbox (binarios)
     - ✅ Sí
     - Instalar en ``C:\ARM-Shared\cmsis-toolbox\`` y añadir al PATH de sistema
   * - Arm GNU Toolchain
     - ✅ Sí
     - Instalar en ``C:\ARM-Shared\gcc-arm\`` y añadir al PATH de sistema
   * - VS Code
     - ✅ Sí
     - Usar el instalador *System* en lugar del *User*
   * - Extensiones de VS Code
     - ⚠️ Parcial
     - Cada usuario tiene su propio directorio de extensiones
   * - Artefactos vcpkg
     - ✅ Sí
     - Via ``VCPKG_ROOT`` apuntando a carpeta compartida

Configuración en una máquina compartida
========================================

Ejecuta el siguiente script completo como **Administrador** para configurar
el entorno compartido de una sola vez:

.. code-block:: powershell

   # ── Crear carpetas compartidas ───────────────────────────────────────────
   New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\Packs"
   New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\cmsis-toolbox"
   New-Item -ItemType Directory -Force -Path "C:\ARM-Shared\vcpkg"

   # ── Permisos: lectura para todos, escritura para admins ──────────────────
   icacls "C:\ARM-Shared" /grant "Users:(OI)(CI)R"          /T
   icacls "C:\ARM-Shared" /grant "Administrators:(OI)(CI)F"  /T

   # ── Variables de entorno de sistema ─────────────────────────────────────
   [System.Environment]::SetEnvironmentVariable(
       "CMSIS_PACK_ROOT", "C:\ARM-Shared\Packs",   "Machine")
   [System.Environment]::SetEnvironmentVariable(
       "VCPKG_ROOT",      "C:\ARM-Shared\vcpkg",   "Machine")
   [System.Environment]::SetEnvironmentVariable(
       "VCPKG_DOWNLOADS", "C:\ARM-Shared\vcpkg\downloads", "Machine")

   # ── Añadir CMSIS-Toolbox al PATH de sistema ──────────────────────────────
   $oldPath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
   $toolboxBin = "C:\ARM-Shared\cmsis-toolbox\bin"
   if ($oldPath -notlike "*$toolboxBin*") {
       [System.Environment]::SetEnvironmentVariable(
           "PATH", "$oldPath;$toolboxBin", "Machine")
   }

   Write-Host "Entorno compartido configurado correctamente." -ForegroundColor Green

Configuración de VS Code por usuario
======================================

Cada usuario debe añadir la siguiente configuración en sus *User Settings*
de VS Code (:kbd:`Ctrl+,` → icono de archivo JSON):

.. code-block:: json

   {
     "cmsis-csolution.packRoot": "C:\\ARM-Shared\\Packs"
   }

O bien propagarlo a través de un archivo ``.vscode/settings.json`` en cada
repositorio de proyecto (se aplica a todos los usuarios que abran ese proyecto):

.. code-block:: json

   {
     "cmsis-csolution.packRoot": "C:\\ARM-Shared\\Packs"
   }

.. tip::

   Commitea el archivo ``.vscode/settings.json`` en el repositorio Git del
   proyecto para que todos los desarrolladores hereden la configuración
   automáticamente al clonar.

Tareas de mantenimiento
========================

Las siguientes tareas deben realizarse por un **Administrador**:

.. list-table::
   :header-rows: 1
   :widths: 40 60

   * - Tarea
     - Comando
   * - Actualizar el índice de paquetes
     - ``cpackget update-index``
   * - Instalar un paquete nuevo para todos
     - ``cpackget add Vendor::PackName``
   * - Actualizar un paquete existente
     - ``cpackget update Vendor::PackName``
   * - Ver paquetes instalados
     - ``cpackget list``
