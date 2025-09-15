================================
Ejemplos de uso de CMSIS RTOS V2
================================

El repositorio contiene los ejemplos básicos para entender el funcionamiento de la API CMSIS-RTOS V2 utilizando el sistema operativo RTX version 5.
Los ejemplos estan implementados para utilizar minimamente los periféricos del microcontrolador y hacer hincapie en los conceptos de manejo del Sistema Operativo.

Los ejemplos se han implementado para el STM32F429 utilizado en la asignatura **Sistemas Basados en microprocesador** y se pueden ejecutar utilizando el simulador del microprocesador includido en el entorno de keil Microvision o bien el hardware.

*******************
Descarga del código
*******************

Para descargar el código puede utilizar un cliente de git en su ordenador o bien descargar el repositorio completo (formato **zip**). Las instruciones para clonar el repositorio son:

.. note:: Descarga del código

    .. code-block:: shell 
    
      $ git clone https://github.com/mruizglz/SBM-rtos.git





*****************************
Listado de ejemplos incluidos
*****************************

.. list-table:: Ejemplos incluidos
   :header-rows: 1

   * - Carpeta
     - Objetivos
   * - **ejemplothreads**
     - Aprender el manejo básico de creación de threads. Uso de la misma función con parámetros parea crear multiples threads
   * - **ejemplothreads-flags**
     - Sincronización de threads usando flags
   * - **ejemplothreads-queues**
     - Intercambio de datos entre threads usando colas
   * - **ejemplothreads-timers**
     - Gestion de timers "software"


**********************************
Configuración del Proyecto de Keil
**********************************

-----------------
Uso del simulador
-----------------

Keil Microvision dispone de opciones para configurar donde se ejecutará la aplicación (Icono *Options for Target*). Seleccione **Debug** y active el uso del simulador (**Use Simulator**). 
Es necesario que configure el fichero de inicialización (**Initialization File**) para que cargue el script de configuración del microcontrolador. En este caso, seleccione el fichero ``simulator.ini`` que se encuentra en cada una de las carpetas de ejmplo. Por ejemplo en la carpeta ``.\ejemplothreads`` del repositorio encontrará el fichero **simulador.ini** con este contenido:

.. literalinclude:: ../ejemplothreads/simulator.ini
  :language: ini
  :linenos:
  

El significado de estas instrucciones es habilitar para el simulador las operaciones de lectura  escritura en las zonas de memoria donde se encuentran los periféricos.

.. tip:: 

   Cuando se usa el simulador de Keil las operaciones de escritura y lectura de los periféricos no tienen ningún efecto y por tanto no podrá simular el comportamiento hardware de los mismos
   Todas las operaciones de la capa HAL que actuan sobre periféricos no tendrán ningún efecto. Por ejemplo, si en el código se configura un pin como salida y luego se escribe un valor alto en el mismo, no podrá ver ningún cambio en el estado del pin.


Como podrá ver en el codigo del programa ``main.c`` existe compilación condicional para incluir o no el código de configuración del RCC para usar un reloj externo (HSE). 
Si utiliza el simulador debe desactivar esta opción y usar el reloj interno (HSI) que es el que utiliza el simulador. La pestaña **C/C++(AC6)** permite añadir en ``define`` etiquetas. Incluya ``SIMULATOR`` si quiere utilizar el simulator.

----------------
Uso del hardware
----------------

Si dispone de una placa con el microcontrolador STM32F429 puede ejecutar el código directamente en el hardware. En este caso debe configurar las opciones del proyecto para que utilice el ST-Link en lugar del simulador. 

**No defina la variable** ``SIMULATOR`` en las opciones de compilación para que el circutio de RCC se configure adecadamente. 

