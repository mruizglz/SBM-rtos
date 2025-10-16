***********************************************************************************
**ejemplothreads-timers**: Uso básico de threads y software timers en CMSIS RTOS v2
***********************************************************************************

Esta sección describe el funcionamiento de un programa en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar dos LEDs mediante un hilo y timers software.

-------------------
Descripción General
-------------------

El programa crea un único hilo denominado ``Timers``. Este hilo se encarga de configurar los pines B0 y B7 como salida para excitar los LEDs LD1 y LD2. Ademas crea un timer one-shot y otro periodico. 
El timer one-shot se inicia para que al cabo de 10 segundos se active y en su callback se encienda el led LD1 y se inicie el timer periódico. El timer periódico hace que el led LD2 parpadee cada 500ms.

-------------------
Estructura de Datos
-------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.


---------------------------
Inicialización de los Hilos
---------------------------

La función ``Init_Thread`` realiza las siguientes operaciones:

1. Crea un hilo ``Timers`` con ``osThreadNew``.


---------------------------
Función del Hilo ``Timers``
---------------------------

La función ``Timers(void *arg)`` realiza las siguientes operaciones:
   1. Configura los pines GPIO para los LEDs LD1 y LD2.
   2. Ejecuta un bucle infinito que en cada iteración expera 1 segundo.
   

-----------------------
Uso de HAL y CMSIS RTOS
-----------------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``.

-------------
Código Fuente
-------------

.. code-block:: c
	:linenos:
	:emphasize-lines: 49

	#include "cmsis_os2.h"                          // CMSIS RTOS header file
	#include "stm32f4xx_hal.h"
	#include <string.h>
	#include <stdlib.h>


	void Init_Threads (void);
	void Timers (void*);
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


	typedef struct  {
		GPIO_InitTypeDef pin;
			GPIO_TypeDef *port;
	} mygpio_pin;

	mygpio_pin pinB0;
	mygpio_pin pinB7;
	void Timer1_Callback_1(void *arg);
	void Timer1_Callback_2(void *arg);
	osTimerId_t timsoft2 ;
	void Init_Threads(void){
		osThreadId_t tid_Thread = osThreadNew(Timers, NULL, NULL);
	}
	void Timers (void* arg) {


		__HAL_RCC_GPIOB_CLK_ENABLE();

		HAL_GPIO_Init(GPIOB, &led_ld1);

		HAL_GPIO_Init(GPIOB, &led_ld2);
		HAL_GPIO_WritePin(GPIOB, led_ld1.Pin, GPIO_PIN_RESET);
		HAL_GPIO_WritePin(GPIOB, led_ld2.Pin, GPIO_PIN_RESET);

		osTimerId_t timsoft1 = osTimerNew(Timer1_Callback_1, osTimerOnce, NULL, NULL);

		osTimerStart(timsoft1,10000);
		timsoft2 = osTimerNew(Timer1_Callback_2, osTimerPeriodic, NULL, NULL);


	while(1){
			osDelay(1000);
	}
	}
	void Timer1_Callback_1(void *arg){

				HAL_GPIO_TogglePin(GPIOB,led_ld1.Pin);
				osTimerStart(timsoft2, 500);

	}

	void Timer1_Callback_2(void *arg){

				HAL_GPIO_TogglePin(GPIOB,led_ld2.Pin);

	}


------------
Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.

------------------------------------------------------
Preguntas y respuestas sobre **ejemplothreads-timers**
------------------------------------------------------

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.

.. contents:: Tabla de contenido
   :depth: 1
   :local:

--------------------------------------------------------------------------------------------------------------------------
Los ficheros RTX_config.h y RTX_config.c son generados automáticamente por el entorno de desarrollo. ¿Se pueden modificar?
--------------------------------------------------------------------------------------------------------------------------

Sí, se pueden modificar. Estos ficheros contienen configuraciones específicas del sistema operativo en tiempo real (RTOS) RTX, como el número máximo de hilos, la prioridad de los hilos, el tamaño de la pila, entre otros parámetros. 
Modificar estos archivos permite ajustar el comportamiento del RTOS según las necesidades específicas de la aplicación.
----------------------------------------------------------------------------------------------------
Si se fija un punto de ruptura en la línea 49, ¿qué se espera ver en el ``Watch Windows->RTX RTOS``?
----------------------------------------------------------------------------------------------------


1. El hilo en estado running. Además no es el único hilo porque aparece el hilo ``osRtxIdleThread`` y ``osRtxTimerThread``.
2. Se visualiza una cola que es utiliza por el sistema operativo para gestionar eventos internos.


.. note:: 
   Challenge: Investigue el mecanismo para pode poner su código en el thread ``osRtxIdleThread``.


