.. _ejemplothread:


 Uso básico de un thread en CMSIS RTOS v2
=========================================

Esta sección describe el funcionamiento de un programa (**ejemplothread**) en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar un LED mediante un hilo.


Descripción General de **ejemplothread** 
-----------------------------------------

El programa crea un hilo que maneja un LED conectado al pin PB0  del microcontrolador STM32F4.El hilo alterna el estado del LED con una frecuencia configurable, utilizando funciones del sistema operativo en tiempo real (RTOS) y la biblioteca HAL para la configuración y manipulación de los pines GPIO.


Estructura de Datos
-------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.
- ``int delay``: retardo en ms entre cada cambio de estado del LED.
- ``uint8_t counter``: contador que se alterna en cada iteración del hilo.

Esta estructura permite pasar todos los parámetros necesarios a la función del hilo de forma organizada.


Inicialización de los hilos
---------------------------

La función ``Init_Thread`` realiza las siguientes tareas:

1. Habilita el reloj del puerto GPIOB.
2. Configura ``mygpio_pin`` para el pin PB0.
3. Crea un hilo con ``osThreadNew``, que ejecuta la función ``Thread`` pasándole una estructura ``mygpio_pin`` para el pin PB0.


Función del hilo
----------------

La función ``Thread`` realiza lo siguiente:

1. Inicializa el pin GPIO usando ``HAL_GPIO_Init``.
2. Entra en un bucle infinito donde:
   - Alterna el valor del contador con ``~counter``.
   - Cambia el estado del pin con ``HAL_GPIO_TogglePin``.
   - Espera el tiempo definido en ``delay`` usando ``osDelay``.

Esto provoca que el LED conectado al pin correspondiente parpadee con una frecuencia que es configurable.


Uso de HAL y CMSIS RTOS
-----------------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``.


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

   

    typedef struct {
        GPIO_InitTypeDef pin;
        GPIO_TypeDef *port;
        int delay;
        uint8_t counter;
    } mygpio_pin;

    mygpio_pin pinB0;
  

    int Init_Thread(void) {
        __HAL_RCC_GPIOB_CLK_ENABLE();

        pinB0.pin = led_ld1;
        pinB0.port = GPIOB;
        pinB0.delay = 15;
        pinB0.counter = 1;
        tid_Thread = osThreadNew(Thread, (void *)&pinB0, NULL);
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


Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.


Preguntas y respuestas sobre **ejemplothread**
----------------------------------------------

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.



¿Qué hace este código?
^^^^^^^^^^^^^^^^^^^^^^

Este código crea un hilo (thread) que controla un LED conectado al pin PB0 de una placa STM32F429. El hilo alterna el estado del LED (encendido/apagado) con una frecuencia determinada utilizando funciones del sistema operativo en tiempo real CMSIS RTOS v2.
Dentro del código del Thread se realiza un casting al tipo de estructura que se utiliza en el ejemplo



¿Qué es la estructura `mygpio_pin`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Es una estructura de datos que encapsula la información necesaria para controlar un pin GPIO en este ejemplo:

- ``pin``: configuración del pin (tipo, velocidad, modo).
- ``port``: puerto GPIO al que pertenece el pin (por ejemplo, GPIOB).
- ``delay``: retardo en ms entre cada cambio de estado (toggle).
- ``counter``: variable auxiliar que cuenta la cantidad de veces que se ha realizado el toggle.


¿Cómo se inicializa el hilo?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

La función ``Init_Thread()`` habilita el reloj del puerto GPIOB, rellena los parámetros de la estructura y crea un hilo con la función ``osThreadNew()``, pasando como argumento la estructura ``mygpio_pin`` correspondiente a cada LED.


¿Qué hace la función `Thread()`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

La función ``Thread(void *argument)`` se encarga de:

1. Inicializar el pin GPIO usando ``HAL_GPIO_Init``.
2. Ejecutar un bucle infinito donde:
   - Se incrementa el valor de  ``counter``.
   - Se cambia el estado del LED con ``HAL_GPIO_TogglePin``.
   - Se espera el tiempo definido en ``delay`` usando ``osDelay``.



¿Qué significa `osDelay()`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Es una función del RTOS que suspende la ejecución del hilo actual durante un número determinado de ms. 
Esto permite que otros hilos se ejecuten mientras tanto. ``osDelay`` tiene como parámetro el número de ticks que la tarea estará bloqueada. 
El número de ticks por segundo se define en el archivo ``RTX_Config.h`` (parámetro ``Kernel Tick Frequency [Hz]``). En este ejemplo se ha configurado a 1000, por lo que un tick equivale a 1 ms.



¿Qué pasa si `osThreadNew()` devuelve NULL?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Significa que no se pudo crear el hilo. En ese caso, la función ``Init_Thread()`` devuelve -1 como señal de error. Si el programa principal que llama a esta función no comprueba el retorno no hay ningún control de errores.


¿Qué ficheros de cabecera se utilizan?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- ``cmsis_os2.h``: para funciones del sistema operativo en tiempo real.
- ``stm32f4xx_hal.h``: para funciones de acceso a hardware (HAL).
- ``stdlib.h``: para funciones estándar de C que en este caso no se están incluyendo en el código.


Determine la carga de la CPU en esta aplicación
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Para determinar la carga que supone la ejecución del thread para la CPU se puede utilizar la utilidad de ``Performance Analyzer`` en modo simulación. 
La carga de CPU obtenida es insignificante. Si se cambia en la estructura de datos el campo ``delay`` por 0 la carga del Thread pasa a ser del 19%.