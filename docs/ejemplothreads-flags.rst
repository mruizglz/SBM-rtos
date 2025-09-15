*************************************************************************
**ejemplothreads-flags**: Uso básico de threads y flags en CMSIS RTOS v2
*************************************************************************

Este documento describe el funcionamiento de un programa en C que utiliza CMSIS RTOS v2 y la biblioteca HAL de STM32 para controlar dos LEDs mediante hilos concurrentes que se comunican con colas.

-------------------
Descripción General
-------------------

El programa crea dos hilos, denominados ``Producer`` y ``Consumer``.  El hilo ``Producer`` es un bucle infinito que se encarga de activar flags para el thread ``Consumer``. Este en función de los flags activados ejecuta unas acciones u otras. 

-------------------
Estructura de Datos
-------------------

Se define una estructura llamada ``mygpio_pin`` que encapsula toda la información necesaria para controlar un LED:

- ``GPIO_InitTypeDef pin``: configuración del pin (modo, velocidad, tipo de salida).
- ``GPIO_TypeDef *port``: puerto GPIO al que pertenece el pin.


Esta estructura permite pasar todos los parámetros necesarios a la función del hilo de forma organizada.

---------------------------
Inicialización de los Hilos
---------------------------

La función ``Init_Thread`` realiza las siguientes operaciones:

1. Crea una cola con ``osMessageQueueNew`` para almacenar hasta 16 mensajes cada uno de tamaño un ``uint8_t``, es decir, un solo byte.
2. Crea un hilo ``Consumer`` con ``osThreadNew``, ejecutando la función ``Consumer``.
3. Crea un hilo ``Producer`` con ``osThreadNew``, ejecutando la función ``Producer``.


-------------------------
Función del Hilo Producer
-------------------------

La función ``Producer(void *argument)`` realiza las siguientes operaciones:
1. De manera continua en un bucle infinito señaliza flags en el thread ``Consumer``. 
2. Los flags activados son el 0x0001 y en 0x0002.

   
-------------------------
Función del Hilo Consumer
-------------------------
La función ``Consumer(void *argument)`` realiza las siguientes operaciones:
1. Inticializa  dos pines del GPIO en el puerto B.
2. Espera de manera infinita (``osWaitForEver``) a que cualquiera  (``osFlagsWaitAny``) de los flags (``0`` o ``1``, en hexadecimal ``0x03``) se activen.
3. Si el flag activado es el ``0`` se hace un toggle en el pin 0 del GPIOB. Si el activado es el ``1`` se hace el toggle en el pin 7 del GPIOB.
4. Si se produce otra condición se incrementa la variable ``errors``.

-----------------------
Uso de HAL y CMSIS RTOS
-----------------------

- **HAL (Hardware Abstraction Layer)**: se utiliza para configurar e inicializar los pines GPIO de forma sencilla y portable.
- **CMSIS RTOS v2**: proporciona las funciones para crear y gestionar hilos, como ``osThreadNew`` y ``osDelay``.

-------------
Código Fuente
-------------

.. code-block:: c

	#include "cmsis_os2.h"                          // CMSIS RTOS header file
	#include "stm32f4xx_hal.h"
	#include <string.h> 
	#include <stdlib.h>
	

	osThreadId_t tid_Thread_producer;                        // thread id
	osThreadId_t tid_Thread_consumer;
	int Init_Thread (void);  
	void Producer (void *argument);                   // thread function producing data
	void Consumer (void *argument);                   // thread function consuming data
	int qsize=0;
	uint8_t a=0;
	uint8_t b=0;

	typedef struct  {
		GPIO_InitTypeDef pin;
			GPIO_TypeDef *port;
	} mygpio_pin;

	mygpio_pin pinB0;
	mygpio_pin pinB7;

	int Init_Thread (void) {
	
		
	
		
	tid_Thread_producer = osThreadNew(Producer, NULL, NULL);
	if (tid_Thread_producer == NULL) {
		return(-1);
	}
		
		tid_Thread_consumer = osThreadNew(Consumer, NULL, NULL);
	if (tid_Thread_consumer == NULL) {
		return(-1);
	}
	
	return(0);
	}
	
	void Producer (void *argument) {
		
		uint32_t status;
	while (1) {
			
				
					status= osThreadFlagsSet(tid_Thread_consumer,0x0001);
					osDelay(1000);
					status= osThreadFlagsSet(tid_Thread_consumer,0x0002);
					osDelay(1000);
			
		}
	}
	void Consumer (void *argument) {
		uint8_t val=0;
		uint32_t status;
		int errors=0;
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
		__HAL_RCC_GPIOB_CLK_ENABLE();
		
		HAL_GPIO_Init(GPIOB, &led_ld1);
		
		HAL_GPIO_Init(GPIOB, &led_ld2);
		
			
	while (1) {
		status=osThreadFlagsWait(0x3,osFlagsWaitAny,osWaitForever);
			switch (status){
				case 1:
					HAL_GPIO_TogglePin(GPIOB,led_ld1.Pin);
					a=!a;
					break; 
			case 2:
					HAL_GPIO_TogglePin(GPIOB,led_ld2.Pin);
				b=!b;
					break;
			default:errors++;
					break;			
			}
			
			
		}
	}


------------
Dependencias
------------

- Librería HAL de STM32.
- CMSIS RTOS v2.

-----------------------------------------------------
Preguntas y respuestas sobre **ejemplothreads-flags**
----------------------------------------------------- 

Esta sección contiene una serie de preguntas con sus respectivas respuestas sobre el funcionamiento del código que utiliza CMSIS RTOS v2 para controlar LEDs en una placa STM32.

.. contents:: Tabla de contenido
   :depth: 1
   :local:


^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Se modifica el código del Producer para que envíe ambas señales (0x0001 y 0x0002) de forma casi simultánea, seguido de un delay de 1 segundo:
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


.. code-block:: c
	:linenos:

	void Producer (void *argument) {
		uint32_t status;
		while (1) {
			status = osThreadFlagsSet(tid_Thread_consumer, 0x0001);
			status = osThreadFlagsSet(tid_Thread_consumer, 0x0002);
			osDelay(1000);
		}
	}


Analice el comportamiento resultante del sistema y responda:

1. ¿Qué valor tendría la variable status en el Consumer después de osThreadFlagsWait?
2. ¿Cómo afecta esta modificación al parpadeo de los LEDs?

1. Valor de status: La variable status en el Consumer tendría el valor 0x0003 (0x0001 | 0x0002), ya que los flags se acumulan en el sistema CMSIS-RTOS cuando se envían antes de que el thread destino los procese.

2. Efecto en los LEDs: Los LEDs dejarían de parpadear por completo. El switch statement en el Consumer solo maneja explícitamente los casos 1 (0x0001) y 2 (0x0002). Al recibir el valor combinado 3, la ejecución cae en el caso default, donde solo se incrementa la variable errors sin ejecutar ninguna operación de toggle en los GPIOs.

