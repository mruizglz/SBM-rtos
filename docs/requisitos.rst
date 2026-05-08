.. _requisitos:

===================
Requisitos previos
===================

Software que se instalará
=========================

.. list-table::
   :header-rows: 1
   :widths: 30 20 50

   * - Software
     - Versión
     - Propósito
   * - Visual Studio Code
     - Última estable
     - Editor e IDE principal
   * - ARM Keil Studio Pack
     - MDK v6 (última)
     - Extensión de VS Code para desarrollo embebido ARM
   * - CMSIS-Toolbox
     - Última (vía vcpkg)
     - Herramientas de línea de comandos: ``cbuild``, ``cpackget``, ``csolution``
   * - Arm GNU Toolchain (GCC)
     - 13.x o superior
     - Compilador ``arm-none-eabi-gcc``
   * - CMake
     - 3.25 o superior
     - Sistema de build
   * - Ninja
     - 1.10 o superior
     - Generador de build rápido
   * - Paquete Keil::STM32F4xx\_DFP
     - 2.17.x o superior
     - Soporte de dispositivo para STM32F4
   * - Paquete ARM::CMSIS
     - 6.x
     - Núcleo CMSIS, headers Cortex-M

Hardware necesario
==================

* Ordenador con Windows 10/11 (64 bits).
* *(Opcional)* Placa STM32F429I-Discovery con cable USB para depuración en hardware real.
* *(Opcional)* Sonda ST-LINK V2/V3.

.. note::

   El compilador y las herramientas se descargan automáticamente por la
   extensión ARM Keil Studio Pack a través de **vcpkg** la primera vez que
