================================
Ejemplos de uso de CMSIS RTOS V2
================================

El repositorio contiene los ejemplos básicos para entender el funcionamiento de la API CMSIS-RTOS V2 utilizando el sistema operativo RTX version 5.
Los ejemplos estan implementados para utilizar minimamente los periféricos del microcontrolador y hacer hincapie en los conceptos de manejo del Sistema OPerativo.

Los ejemplos se han implementado para el STM32F429 utilizado en la asignatura Sistemas Basados en microprocesador y se pueden ejecutar utilizando el simulador del microprocesador includido en el entorno de keil Microvision  o bien el hardware.

*******************
Descarga del código
*******************

.. note:: Descarga del código

    .. code-block:: shell 
    
      git clone https://github.com/mruizglz/SBM-rtos.git





*******************
Ejemplos incluidos
*******************


.. list-table:: Ejemplos incluidos
   :header-rows: 1

   * - Carpeta
     - Objetivos
   * - ejemplothreads
     - Aprender el manejo básico de creación de threads. Uso de la misma función con parámetros parea crear multiples threads
   * - ejemplothreads-flags
     - Sincronización de threads usando flags
   * - ejemplothreads-queues
     - Intercambio de datos entre threads usando colas 
   * - ejemplothreads-timers
     - Gestion de timers "software"


**************************
Configuración del Proyecto
**************************

