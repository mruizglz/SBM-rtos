.. _ejemplothreads:


Uso básico de threads en CMSIS RTOS v2
======================================

Esta sección describe el funcionamiento de un programa en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar dos LEDs mediante hilos concurrentes.


Descripción General
-------------------

El programa crea dos hilos que controlan dos LEDs conectados a los pines PB0 y PB7 del microcontrolador STM32F429. Cada hilo alterna el estado de su LED con una frecuencia distinta, utilizando funciones del sistema operativo en tiempo real (RTOS) y la biblioteca HAL para la configuración y manipulación de los pines GPIO.


Estructura mygpio_pin
---------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.
- ``int delay``: retardo en ms entre cada cambio de estado del LED.
- ``uint8_t counter``: contador que se incrementa en cada iteración del hilo.

Esta estructura permite pasar todos los parámetros necesarios a la función del hilo de forma organizada.


Inicialización de los threads
-----------------------------

La función ``Init_Thread`` realiza las siguientes tareas:

1. Habilita el reloj del puerto GPIOB.
2. Configura dos instancias de ``mygpio_pin`` para los pines PB0 y PB7.
3. Crea dos hilos con ``osThreadNew``, cada uno ejecutando la función ``Thread`` con una instancia diferente de ``mygpio_pin``.

Cada hilo se ejecuta de forma independiente y controla su propio LED.


``Thread()``
------------

La función ``Thread`` realiza lo siguiente:

1. Inicializa el pin GPIO usando ``HAL_GPIO_Init``.
2. Entra en un bucle infinito donde:
   - Alterna el valor del contador con ``~counter``.
   - Cambia el estado del pin con ``HAL_GPIO_TogglePin``.
   - Espera el tiempo definido en ``delay`` usando ``osDelay``.

Esto provoca que el LED conectado al pin correspondiente parpadee con una frecuencia determinada.


HAL y CMSIS RTOS
----------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``.


Código
------

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


Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.


Preguntas y respuestas sobre **ejemplothreads** 
------------------------------------------------

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.


¿Qué función hace este código?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Este código crea dos hilos (threads) que controlan dos LEDs conectados a los pines PB0 y PB7 de una placa STM32F4. Cada hilo alterna el estado del LED (encendido/apagado) con una frecuencia determinada utilizando funciones del sistema operativo en tiempo real CMSIS RTOS v2.
Es importante entender que el mismo código (funcion Thread) es ejecutado por dos hilos diferentes, cada uno con sus propios parámetros, que se reciben en el argumento de la función.
Es de tipo ``void`` para poder pasar cualquier tipo de estructura como argumento. Dentro del código del Thread se realiza un casting al tipo de estructura que se utiliza en el ejemplo


¿Qué  función tiene `mygpio_pin`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Es una estructura de datos que encapsula la información necesaria para controlar un pin GPIO en este ejemplo:

- ``pin``: configuración del pin (tipo, velocidad, modo).
- ``port``: puerto GPIO al que pertenece el pin (por ejemplo, GPIOB).
- ``delay``: retardo en ms entre cada cambio de estado (toggle).
- ``counter``: variable auxiliar que cuenta la cantidad de veces que se ha realizado el toggle.



¿Cómo se inicializan los hilos?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

La función ``Init_Thread()`` habilita el reloj del puerto GPIOB, configura los parámetros de cada LED y crea dos hilos con ``osThreadNew()``, pasando como argumento la estructura ``mygpio_pin`` correspondiente a cada LED.


¿Qué función tieneº `Thread()`?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

La función ``Thread(void *argument)`` es ejecutada por cada hilo. Dentro de ella:

1. Se inicializa el pin GPIO usando ``HAL_GPIO_Init``.
2. Se entra en un bucle infinito donde:
   - Se alterna el valor de ``counter``.
   - Se cambia el estado del LED con ``HAL_GPIO_TogglePin``.
   - Se espera el tiempo definido en ``delay`` usando ``osDelay``.


¿Se ejecutan los hilos al mismo tiempo?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

CMSIS RTOS v2 permite la ejecución concurrente, que no simultanea, de múltiples hilos. El scheduler del sistema operativo se encarga de asignar tiempo de CPU a cada hilo según su estado y prioridad.



¿Qué significa ``osDelay()``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Es una función del RTOS que suspende la ejecución del hilo actual durante un número determinado de ticks. Esto permite que otros hilos se ejecuten mientras tanto. ``osDelay`` tiene como parametro el número de ticks que la tarea estará bloqueada. El número de ticks por segundo se define en el archivo ``RTX_Config.h`` (parámetro ``Kernel Tick Frequency [Hz]``). En este ejemplo se ha configurado a 1000, por lo que un tick equivale a 1 ms.



¿Qué pasa si `osThreadNew()` devuelve NULL?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Significa que no se pudo crear el hilo. En ese caso, la función ``Init_Thread()`` devuelve -1 como señal de error.


¿Qué includes se utilizan?
^^^^^^^^^^^^^^^^^^^^^^^^^^

- ``cmsis_os2.h``: para funciones del sistema operativo en tiempo real.
- ``stm32f4xx_hal.h``: para funciones de acceso a hardware (HAL).
- ``stdlib.h``: para funciones estándar de C.
  

¿Cuanto vale el valor del tick es esta aplicación?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

El fichero de configuración del sistema operativo tal y como indica la figura tiene configurado un tick de 1ms. 

.. figure:: ../presentation/RTXConfig.png
   :scale: 50 %
   :align: center
   :figwidth: 400px

   Configuración del sistema operativo.


¿Que es el thread Idle? ¿Qué tamaño de stack tiene? ¿Y otro thread? ¿Que tamaño de stack usa?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

El thread idle esta definido en el fichero RTX_Config.c y es un thread que se ejecuta cuando el sistema operativo no tiene ninguna otro thread que ejecutar. Tiene un tamaño de ``stack`` de 512 bytes.
Cualquier otro thread se configura para tener un tamaño de stack de 3072 bytes (3KBytes). Una reflexión interesante es cuantos threads se pueden crear en una aplicación.
