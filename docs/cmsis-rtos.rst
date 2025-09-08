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

**********************************************************
**ejemplothreads**: Uso básico de threads en CMSIS RTOS v2
**********************************************************

Este documento describe el funcionamiento de un programa en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar dos LEDs mediante hilos concurrentes.

-------------------
Descripción General
-------------------

El programa crea dos hilos que controlan dos LEDs conectados a los pines PB0 y PB7 del microcontrolador STM32F4. Cada hilo alterna el estado de su LED con una frecuencia distinta, utilizando funciones del sistema operativo en tiempo real (RTOS) y la biblioteca HAL para la configuración y manipulación de los pines GPIO.

-------------------
Estructura de Datos
-------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.
- ``int delay``: retardo en milisegundos entre cada cambio de estado del LED.
- ``uint8_t counter``: contador que se alterna en cada iteración del hilo.

Esta estructura permite pasar todos los parámetros necesarios a la función del hilo de forma organizada.

---------------------------
Inicialización de los Hilos
---------------------------

La función ``Init_Thread`` realiza las siguientes tareas:

1. Habilita el reloj del puerto GPIOB.
2. Configura dos instancias de ``mygpio_pin`` para los pines PB0 y PB7.
3. Crea dos hilos con ``osThreadNew``, cada uno ejecutando la función ``Thread`` con una instancia diferente de ``mygpio_pin``.

Cada hilo se ejecuta de forma independiente y controla su propio LED.

----------------
Función del Hilo
----------------

La función ``Thread`` realiza lo siguiente:

1. Inicializa el pin GPIO usando ``HAL_GPIO_Init``.
2. Entra en un bucle infinito donde:
   - Alterna el valor del contador con ``~counter``.
   - Cambia el estado del pin con ``HAL_GPIO_TogglePin``.
   - Espera el tiempo definido en ``delay`` usando ``osDelay``.

Esto provoca que el LED conectado al pin correspondiente parpadee con una frecuencia determinada.

-----------------------
Uso de HAL y CMSIS RTOS
-----------------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``.

-------------
Código Fuente
-------------

.. code-block:: c

    #include "cmsis_os2.h"
    #include "stm32f4xx_hal.h"
    #include <stdlib.h>

    osThreadId_t tid_Thread;

    GPIO_InitTypeDef led_ld1 = {
        .Pin = GPIO_PIN_0,
        .Mode = GPIO_MODE_OUTPUT_PP,
        .Pull = GPIO_NOPULL,
        .Speed = GPIO_SPEED_FREQ_LOW
    };

    GPIO_InitTypeDef led_ld2 = {
        .Pin = GPIO_PIN_7,
        .Mode = GPIO_MODE_OUTPUT_PP,
        .Pull = GPIO_NOPULL,
        .Speed = GPIO_SPEED_FREQ_LOW
    };

    typedef struct {
        GPIO_InitTypeDef pin;
        GPIO_TypeDef *port;
        int delay;
        uint8_t counter;
    } mygpio_pin;

    mygpio_pin pinB0;
    mygpio_pin pinB7;

    int Init_Thread(void) {
        __HAL_RCC_GPIOB_CLK_ENABLE();

        pinB0.pin = led_ld1;
        pinB0.port = GPIOB;
        pinB0.delay = 15;
        pinB0.counter = 1;
        tid_Thread = osThreadNew(Thread, (void *)&pinB0, NULL);
        if (tid_Thread == NULL) return -1;

        pinB7.pin = led_ld2;
        pinB7.port = GPIOB;
        pinB7.delay = 10;
        pinB7.counter = 0;
        tid_Thread = osThreadNew(Thread, (void *)&pinB7, NULL);
        if (tid_Thread == NULL) return -1;

        return 0;
    }

    void Thread(void *argument) {
        mygpio_pin *gpio = (mygpio_pin *)argument;
        HAL_GPIO_Init(gpio->port, &(gpio->pin));
        while (1) {
            gpio->counter++;
            HAL_GPIO_TogglePin(gpio->port, gpio->pin.Pin);
            osDelay(gpio->delay);
        }
    }

------------
Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.

----------------------------------------------
Preguntas y respuetas sobre **ejemplothreads**
----------------------------------------------

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.

.. contents:: Tabla de contenido
   :depth: 1
   :local:

----------------------
¿Qué hace este código?
----------------------

Este código crea dos hilos (threads) que controlan dos LEDs conectados a los pines PB0 y PB7 de una placa STM32F4. Cada hilo alterna el estado del LED (encendido/apagado) con una frecuencia determinada utilizando funciones del sistema operativo en tiempo real CMSIS RTOS v2.
Es importante entender que el mismo codigo (funcion Thread) es ejecutado por dos hilos diferentes, cada uno con sus propios parámetros, que se reciben en el argumento de la función.
Es de tipo ``void`` para poder pasar cualquier tipo de estructura como argumento. Dentro del codigo del Thread se realiza un casting al tipo de estructura que se utiliza en el ejemplo


-----------------------------------
¿Qué es la estructura `mygpio_pin`?
-----------------------------------

Es una estructura de datos que encapsula la información necesaria para controlar un pin GPIO en este ejemplo:

- ``pin``: configuración del pin (tipo, velocidad, modo).
- ``port``: puerto GPIO al que pertenece el pin (por ejemplo, GPIOB).
- ``delay``: retardo en milisegundos entre cada cambio de estado (toggle).
- ``counter``: variable auxiliar que cuenta la cantidad de veces que se ha realizado el toggle.

-------------------------------
¿Cómo se inicializan los hilos?
-------------------------------

La función ``Init_Thread()`` habilita el reloj del puerto GPIOB, configura los parámetros de cada LED y crea dos hilos con ``osThreadNew()``, pasando como argumento la estructura ``mygpio_pin`` correspondiente a cada LED.

--------------------------------
¿Qué hace la función `Thread()`?
--------------------------------

La función ``Thread(void *argument)`` es ejecutada por cada hilo. Dentro de ella:

1. Se inicializa el pin GPIO usando ``HAL_GPIO_Init``.
2. Se entra en un bucle infinito donde:
   - Se alterna el valor de ``counter``.
   - Se cambia el estado del LED con ``HAL_GPIO_TogglePin``.
   - Se espera el tiempo definido en ``delay`` usando ``osDelay``.

---------------------------------------
¿Se ejecutan los hilos al mismo tiempo?
---------------------------------------

CMSIS RTOS v2 permite la ejecución concurrente, que no simultanea, de múltiples hilos. El scheduler del sistema operativo se encarga de asignar tiempo de CPU a cada hilo según su estado y prioridad.


---------------------------
¿Qué significa `osDelay()`?
---------------------------

Es una función del RTOS que suspende la ejecución del hilo actual durante un número determinado de milisegundos. Esto permite que otros hilos se ejecuten mientras tanto. ``osDelay`` tiene como parametro el número de ticks que la tarea estará bloqueada. El número de ticks por segundo se define en el archivo ``RTX_Config.h`` (parámetro ``Kernel Tick Frequency [Hz]``). En este ejemplo se ha configurado a 1000, por lo que un tick equivale a 1 ms.


-------------------------------------------
¿Qué pasa si `osThreadNew()` devuelve NULL?
-------------------------------------------

Significa que no se pudo crear el hilo. En ese caso, la función ``Init_Thread()`` devuelve -1 como señal de error.

---------------------------
¿Qué librerías se utilizan?
---------------------------

- ``cmsis_os2.h``: para funciones del sistema operativo en tiempo real.
- ``stm32f4xx_hal.h``: para funciones de acceso a hardware (HAL).
- ``stdlib.h``: para funciones estándar de C.
