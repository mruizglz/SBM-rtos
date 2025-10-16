================================
Ejemplos de uso de CMSIS RTOS V2
================================

El repositorio contiene los ejemplos básicos para entender el funcionamiento de la API CMSIS-RTOS V2 utilizando el sistema operativo RTX version 5.
Los ejemplos están implementados para utilizar mínimamente los periféricos del microcontrolador y hacer hincapié en los conceptos de manejo del Sistema Operativo.

Los ejemplos se han implementado para el STM32F429 utilizado en la asignatura **Sistemas Basados en Microprocesador** de la **(ETSI Sistemas de Telecomunicación) Universidad Politécnica de Madrid** y se pueden ejecutar utilizando el simulador del microprocesador incluido en el entorno de ARM keil Microvision o bien el hardware.

*******************
Descarga del código
*******************

Para descargar el código puede utilizar un cliente de git en su ordenador o bien descargar el repositorio completo (formato **zip**). Las instrucciones para clonar el repositorio son:

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

ARM Keil Microvision dispone de opciones para configurar donde se ejecutará la aplicación (Icono *Options for Target*). Seleccione **Debug** y active el uso del simulador (**Use Simulator**). 
Es necesario que configure el fichero de inicialización (**Initialization File**) para que cargue un script de configuración del microcontrolador. En este caso, seleccione el fichero ``simulator.ini`` que se encuentra en cada una de las carpetas de ejmplo. Por ejemplo en la carpeta ``.\ejemplothreads`` del repositorio encontrará el fichero **simulador.ini** con este contenido:

.. literalinclude:: ../ejemplothreads/simulator.ini
  :language: ini
  :linenos:
  

El significado de estas instrucciones es habilitar para el simulador las operaciones de lectura/escritura en las zonas de memoria donde se encuentran los periféricos.

.. tip:: 

   Cuando se usa el simulador de Keil las operaciones de escritura y lectura de los periféricos no tienen ningún efecto y por tanto no podrá simular el comportamiento hardware de los mismos
   Todas las operaciones de la capa HAL que actúan sobre periféricos no tendrán ningún efecto. Por ejemplo, si en el código se configura un pin como salida y luego se escribe un valor alto en el mismo, no podrá ver ningún cambio en el estado del pin.


Como podrá ver en el código del programa ``main.c`` existe compilación condicional para incluir o no el código de configuración del RCC para usar un reloj externo (HSE). 
Si utiliza el simulador debe desactivar esta opción y usar el reloj interno (HSI) que es el que utiliza el simulador. La pestaña **C/C++(AC6)** permite añadir en ``define`` etiquetas. Incluya ``SIMULATOR`` si quiere utilizar el simulator.

----------------
Uso del hardware
----------------

Si dispone de una placa con el microcontrolador STM32F429 puede ejecutar el código directamente en el hardware. En este caso debe configurar las opciones del proyecto para que utilice el ST-Link en lugar del simulador. 

**No defina la variable** ``SIMULATOR`` en las opciones de compilación para que el circuito de RCC se configure adecuadamente. 


-----------------------------------------------
Depuración de aplicaciones usando CMSIS-RTOS V2
-----------------------------------------------

La depuración de las aplicaciones se debe realizar combinando el uso de puntos de ruptura y de la aplicación RTX RTOS view disponible en el menu ``View->Watch Windows->RTX RTOS``. 
Esta permite ver el estado en el que se encuentran los diferentes objetos del sistema operativo cuando el procesador pausa su ejecución. Herramientas complementarias para entender
el funcionamiento de una aplicación son ``Logyc Analyzer``, ``Performance Analyzer``, ``System Analyzer``, ``Event Recorder``. ``Event Statistics`` y ``Symbols Window``

^^^^^^^^^^^^^^
Symbols Window
^^^^^^^^^^^^^^

La opción **Symbols Window** permite visualizar y explorar todos los símbolos definidos en el proyecto, incluyendo variables globales, variables estáticas, funciones y direcciones de registros . Esta ventana es útil para depuración y análisis en tiempo real.

- Muestra una lista jerárquica de todos los símbolos disponibles en el programa cargado.
- Permite buscar y filtrar símbolos por nombre.
- Muestra la dirección y el valor actual de cada símbolo durante la sesión de depuración.
- Facilita el arrastre de variables a otras ventanas de análisis, como el Watch Window o el Logic Analyzer.
- Permite examinar variables optimizadas si están disponibles en la tabla de símbolos.
- Si un símbolo no aparece, verifique la configuración de optimización del compilador y el ámbito de la variable.

Para utilizarlo:

1. Iniciar una sesión de depuración.
2. Abrir la ventana desde el menú: :menuselection:`View --> Symbol Window`.
3. Buscar el símbolo deseado utilizando el campo de filtro.
4. Arrastrar el símbolo a la ventana de Watch o ``Logic Analyzer`` para su monitorización.


^^^^^^^^^^^^^^
Logic Analyzer
^^^^^^^^^^^^^^

Permite visualizar la evolución temporal de variables que sean globales a la aplicación, el contenido de posiciones de memoria, etc. Se puede configurar el rango de valores y es muy apropiado para comparar visualmente la evolución de la aplicacón software a través del seguimiento de variables.
Para agregar señales al ``Logic Analyzer`` puede arrastrarlas de la ventana de símbolos o escribir el nombre de la misma.

.. figure:: ../presentation/logicanalyzer.png
   :alt: Analizador Lógico
   :scale: 50 %
   :align: center
   :figwidth: 400px

   Analizador lógico de ARM Keil Microvision.


^^^^^^^^^^^^^^^^^^^^
Performance Analyzer
^^^^^^^^^^^^^^^^^^^^

.. warning::

  Solo esta disponible en Simulación porque el ST-LINK no lo soporta


Permite conocer el porcentaje de tiempo utilizado por cada porción del código de nuestra aplicación.
Para utilizarlo:

1. Iniciar una sesión de depuración.
2. Abrir la ventana desde el menú: :menuselection:`View --> Analysis Windows --> Performnace analyzer`.
3. Se muestra una lista de las diferentes secciones de código.

.. figure:: ../presentation/performanceanalyzer.png
   :alt: Performance Analyzer
   :scale: 50 %
   :align: center
   :figwidth: 400px

   Performance Analyzer (Solo disponible en Modo Simulación). No soportado en ST-LINK.


 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
 Código del main.c de los ejemplos
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

El código del programa principal está detallado a continuación y es el mismo o muy similar para todos los ejemplos:

 .. code-block:: c


  #include "main.h"

  #ifdef _RTE_
  #include "RTE_Components.h"             // Component selection
  #endif
  #ifdef RTE_CMSIS_RTOS2                  // when RTE component CMSIS RTOS2 is used
  #include "cmsis_os2.h"                  // ::CMSIS:RTOS2
  #endif

  #ifdef RTE_CMSIS_RTOS2_RTX5
  /**
    * Override default HAL_GetTick function
    */
  uint32_t HAL_GetTick (void) {
    static uint32_t ticks = 0U;
          uint32_t i;

    if (osKernelGetState () == osKernelRunning) {
      return ((uint32_t)osKernelGetTickCount ());
    }

    /* If Kernel is not running wait approximately 1 ms then increment 
      and return auxiliary tick counter value */
    for (i = (SystemCoreClock >> 14U); i > 0U; i--) {
      __NOP(); __NOP(); __NOP(); __NOP(); __NOP(); __NOP();
      __NOP(); __NOP(); __NOP(); __NOP(); __NOP(); __NOP();
    }
    return ++ticks;
  }

  /**
    * Override default HAL_InitTick function
    */
  HAL_StatusTypeDef HAL_InitTick(uint32_t TickPriority) {
    
    UNUSED(TickPriority);

    return HAL_OK;
  }
  #endif
  #include "Timer.h"
  /** @addtogroup STM32F4xx_HAL_Examples
    * @{
    */

  /** @addtogroup Templates
    * @{
    */

  /* Private typedef -----------------------------------------------------------*/
  /* Private define ------------------------------------------------------------*/
  /* Private macro -------------------------------------------------------------*/
  /* Private variables ---------------------------------------------------------*/
  /* Private function prototypes -----------------------------------------------*/
  static void SystemClock_Config(void);
  static void Error_Handler(void);

  /* Private functions ---------------------------------------------------------*/
  /**
    * @brief  Main program
    * @param  None
    * @retval None
    */

  int main(void)
  {

    /* STM32F4xx HAL library initialization:
        - Configure the Flash prefetch, Flash preread and Buffer caches
        - Systick timer is configured by default as source of time base, but user 
              can eventually implement his proper time base source (a general purpose 
              timer for example or other time source), keeping in mind that Time base 
              duration should be kept 1ms since PPP_TIMEOUT_VALUEs are defined and 
              handled in milliseconds basis.
        - Low Level Initialization
      */
    HAL_Init();

    /* Configure the system clock to 168 MHz */
    SystemClock_Config();
    SystemCoreClockUpdate();

    /* Add your application code here
      */

  #ifdef RTE_CMSIS_RTOS2
    /* Initialize CMSIS-RTOS2 */
    osKernelInitialize ();

    /* Create thread functions that start executing, 
    Example: osThreadNew(app_main, NULL, NULL); */
    Init_Threads();
    /* Start thread execution */
    osKernelStart();
  #endif

    /* Infinite loop */
    while (1)
    {
    }
  }

  /**
    * @brief  System Clock Configuration
    *         The system Clock is configured as follow : 
    *            System Clock source            = PLL (HSE)
    *            SYSCLK(Hz)                     = 168000000
    *            HCLK(Hz)                       = 168000000
    *            AHB Prescaler                  = 1
    *            APB1 Prescaler                 = 4
    *            APB2 Prescaler                 = 2
    *            HSE Frequency(Hz)              = 8000000
    *            PLL_M                          = 25
    *            PLL_N                          = 336
    *            PLL_P                          = 2
    *            PLL_Q                          = 7
    *            VDD(V)                         = 3.3
    *            Main regulator output voltage  = Scale1 mode
    *            Flash Latency(WS)              = 5
    * @param  None
    * @retval None
    */
  static void SystemClock_Config(void)
  {
    RCC_ClkInitTypeDef RCC_ClkInitStruct;
    RCC_OscInitTypeDef RCC_OscInitStruct;

    /* Enable Power Control clock */
    __HAL_RCC_PWR_CLK_ENABLE();

    /* The voltage scaling allows optimizing the power consumption when the device is 
      clocked below the maximum system frequency, to update the voltage scaling value 
      regarding system frequency refer to product datasheet.  */
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

    /* Enable HSE Oscillator and activate PLL with HSE as source */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
    RCC_OscInitStruct.HSEState = RCC_HSE_ON;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
    RCC_OscInitStruct.PLL.PLLM = 4;
    RCC_OscInitStruct.PLL.PLLN = 168;
    RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
    RCC_OscInitStruct.PLL.PLLQ = 7;
    if(HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
      /* Initialization Error */
      Error_Handler();
    }

    /* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 
      clocks dividers */
    RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;  
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;  
    if(HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
    {
      /* Initialization Error */
      Error_Handler();
    }

    /* STM32F405x/407x/415x/417x Revision Z devices: prefetch is supported */
    if (HAL_GetREVID() == 0x1001)
    {
      /* Enable the Flash prefetch */
      __HAL_FLASH_PREFETCH_BUFFER_ENABLE();
    }
  }

  /**
    * @brief  This function is executed in case of error occurrence.
    * @param  None
    * @retval None
    */
  static void Error_Handler(void)
  {
    /* User may add here some code to deal with this error */
    while(1)
    {
    }
  }


Algunos detalles importantes:
  
  1. Al utilizar el sistema operativo CMSIS-RTOS V2 se ha definido RTE_CMSIS_RTOS2_RTX5. Esto supone incluir dos funciones que anulan las definidas anteriormente.
  Estas funciones son ``HAL_GetTick``   y ``HAL_InitTick``. La primera tiene dos comportamientos diferentes: 
    * Si el sistema operativo esta en ejecución devuelve el valor retornado por ``osKernelGetTicCount()`` que indica el número de ticks que han pasado desde que se arranco el SO.
    * Si **no** se ha arrancado el SO la función produce un retardo de aproximadamente un 1ms e incrementa la variable estática ticks.
  ``Hal_GetTick`` se utiliza for las librerías HAL de STM para controlar timeouts en la gestión de los periféricos.
  La segunda función, ``HAL_InitTick``, es usada por la capa HAL para programar un timer HW que proporcione una interrupción cada 1ms. Por defecto este timer es el SysTick timer. 
  Cuando no se usa el sistema operativo esta función realiza las operaciones del código descrito en stm32f4xx_hal.c Al usar el SO esta función se substituye por la definida en el ``main.c``, que no realiza ninguna operación. 
  Es el código del sistema operativo quien se encarga de inicializar el SysTick (os_systick.c).

  2. Despues del código de inicialización de la libraría HAL y de la configuración del RCC del micro (que por cierto utiliza la función HAL_GetTick) se procede a ejecutar la siguiente porción de código:
  
  .. code-block:: C

    #ifdef RTE_CMSIS_RTOS2
      /* Initialize CMSIS-RTOS2 */
      osKernelInitialize ();

      /* Create thread functions that start executing, 
      Example: osThreadNew(app_main, NULL, NULL); */
      Init_Threads();
      /* Start thread execution */
      osKernelStart();
    #endif

      /* Infinite loop */
      while (1)
      {
      }

    La función ``osKernelInitialize`` inicializa el Sistema Operativo. La función ``init_Threads`` contiene el código de creación de los recursos necesarios en este ejemplo, y ``osKernelStart`` comienza la ejecución de los diferentes objetos del SO sin retornar.
    eso quiere decir que la porción del código while es código muerto.

  3. Toda la inicialización del hardware se debe hacer antes de lanzar la ejecución del SO. 
     Puede incluirse en el código específico de cada thread, en funciones que se ejecuten entre osKernelInitialize y osKernelStart, o en funciones que se incluyan antes de llamar a osKernelInitialize. En cualquier caso debe tener cuidado con el mecanismo de retardo que utiliza en cada parte de la aplicación.


     .. note::

        No se recomienda el uso de la función HAL_Delay cuando se esta ejecutando el SO porque la función se puede quedar bloqueada.
