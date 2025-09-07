================================
Ejemplos de uso de CMSIS RTOS V2
================================

El repositorio contiene los ejemplos básicos para entender el funcionamiento de la API CMSIS-RTOS V2 utilizando el sistema operativo RTX version 5.
Los ejemplos estan implementados para utilizar minimamente los periféricos del microcontrolador y hacer hincapie en los conceptos de manejo del Sistema OPerativo.

Los ejemplos se han implementado para el STM32F429 utilizado en la asignatura Sistemas Basados en microprocesador y se pueden ejecutar utilizando el simulador del microprocesador includido en el entorno de keil Microvision  o bien el hardware.

*******************
Descarga del código
*******************

Para descrgar el código puede utilizar un cliente de git en su ordenador o bien descargar el repositorio completo. Las instruciones para clonar el repositorio son:

.. note:: Descarga del código

    .. code-block:: shell 
    
      $ git clone https://github.com/mruizglz/SBM-rtos.git





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

-----------------
Uso del simulador
-----------------

En Keil Microvision dispone de opciones para configurar el target (Options for Target). Seleccione Debug y active el uso del simulador (Use Simulator). Configure el fichero 


=====================================
Thread LED Control with CMSIS RTOS v2
=====================================

This example demonstrates how to use CMSIS RTOS v2 to control two LEDs on an STM32F4 board using separate threads.

Overview
--------

Two GPIO pins (PB0 and PB7) are configured as outputs. Each pin is controlled by a separate thread that toggles the LED state with a specific delay.

Code
----

.. code-block:: c

    #include "cmsis_os2.h"                          // CMSIS RTOS header file
    #include "stm32f4xx_hal.h"
    #include <stdlib.h>

    osThreadId_t tid_Thread;                        // thread id

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
            gpio->counter = ~gpio->counter;
            HAL_GPIO_TogglePin(gpio->port, gpio->pin.Pin);
            osDelay(gpio->delay);
        }
    }

Explanation
-----------

- ``Init_Thread`` initializes the GPIO pins and creates two threads.
- Each thread runs the ``Thread`` function, which toggles the LED state.
- The delay between toggles is defined per pin (PB0: 15ms, PB7: 10ms).
- ``HAL_GPIO_TogglePin`` is used to change the LED state.
- ``osDelay`` introduces a delay in the thread execution.

Dependencies
------------

- STM32 HAL library
- CMSIS RTOS v2
- STM32CubeMX (for project setup)


