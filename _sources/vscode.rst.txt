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
