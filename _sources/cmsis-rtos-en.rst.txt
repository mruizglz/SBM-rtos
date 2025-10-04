================================
CMSIS RTOS V2 Usage Examples
================================

The repository contains basic examples to understand how the CMSIS-RTOS V2 API works using the RTX version 5 operating system.
The examples are implemented to make minimal use of the microcontroller peripherals and to emphasize operating system concepts.

The examples have been implemented for the STM32F429 used in the course **Microprocessor-Based Systems** of the **(ETSI Sistemas de Telecomunicación) Universidad Politécnica de Madrid**, and they can be executed using the microprocessor simulator included in the ARM Keil Microvision environment or directly on the hardware.

*******************
Code download
*******************

To download the code you can use a git client on your computer or download the entire repository (in **zip** format). The instructions to clone the repository are:

.. note:: Code download

    .. code-block:: shell 
    
      $ git clone https://github.com/mruizglz/SBM-rtos.git



*****************************
List of included examples
*****************************

.. list-table:: Included examples
   :header-rows: 1

   * - Folder
     - Goals
   * - **ejemplothreads**
     - Learn the basics of creating threads. Use of the same function with parameters to create multiple threads
   * - **ejemplothreads-flags**
     - Thread synchronization using flags
   * - **ejemplothreads-queues**
     - Data exchange between threads using queues
   * - **ejemplothreads-timers**
     - Management of software timers

--------------------------------
Keil Project Configuration
--------------------------------

-----------------
Using the simulator
-----------------

ARM Keil Microvision provides options to configure where the application will run (icon *Options for Target*). Select **Debug** and enable the simulator (**Use Simulator**). You need to configure the **Initialization File** so that it loads a microcontroller configuration script. In this case, select the file ``simulator.ini`` found in each example folder.

For example, in the ``.\ejemplothreads`` folder of the repository you will find the file **simulator.ini** with this content:

.. literalinclude:: ../ejemplothreads/simulator.ini
  :language: ini
  :linenos:
  

The meaning of these instructions is to enable, for the simulator, read/write operations in the memory areas where the peripherals are located.

.. tip:: 

   When using the Keil simulator, write and read operations on peripherals have no effect and therefore you will not be able to simulate their hardware behavior. All operations of the HAL layer that act on peripherals will have no effect. For example, if the code configures a pin as output and then writes a high level to it, you will not see any change in the pin state.


As you can see in the ``main.c`` program code, there is conditional compilation to include or not the RCC configuration code to use an external clock (HSE). If you use the simulator you must disable this option and use the internal clock (HSI), which is what the simulator uses. The **C/C++(AC6)** tab allows you to add labels in **define**. Include ``SIMULATOR`` if you want to use the simulator.

----------------
Using the hardware
----------------

If you have a board with the STM32F429 microcontroller you can run the code directly on the hardware. In this case you must configure the project options so that it uses **ST-Link** instead of the simulator. 

**Do not define** the ``SIMULATOR`` variable in the compilation options so that the RCC circuit is configured properly. 


-----------------------------------------------
Debugging applications using CMSIS-RTOS V2
-----------------------------------------------

Debugging should be performed by combining the use of breakpoints and the **RTX RTOS** view available in the menu ``View->Watch Windows->RTX RTOS``. This allows you to see the state of the different operating system objects when the processor pauses its execution. Complementary tools to understand how an application works are ``Logic Analyzer``, ``Performance Analyzer``, ``System Analyzer``, ``Event Recorder``, ``Event Statistics`` and ``Symbols Window``.

^^^^^^^^^^^^^^
Symbols Window
^^^^^^^^^^^^^^

The **Symbols Window** option allows you to view and explore all the symbols defined in the project, including global variables, static variables, functions and register addresses. This window is useful for real-time debugging and analysis.

- Displays a hierarchical list of all symbols available in the loaded program.
- Allows searching and filtering symbols by name.
- Shows the address and current value of each symbol during the debugging session.
- Facilitates dragging variables to other analysis windows, such as the Watch Window or the Logic Analyzer.
- Allows examining optimized variables if they are available in the symbol table.
- If a symbol does not appear, verify the compiler optimization settings and the variable scope.

To use it:

1. Start a debugging session.
2. Open the window from the menu: :menuselection:`View --> Symbol Window`.
3. Search for the desired symbol using the filter field.
4. Drag the symbol to the Watch window or the ``Logic Analyzer`` for monitoring.


^^^^^^^^^^^^^^
Logic Analyzer
^^^^^^^^^^^^^^

It allows you to visualize the time evolution of variables that are global to the application, the content of memory locations, etc. You can configure the value range and it is very useful to visually compare the evolution of the software application by tracking variables. To add signals to the ``Logic Analyzer`` you can drag them from the Symbol window or type the signal name.

.. figure:: ../presentation/logicanalyzer.png
   :alt: Logic Analyzer
   :scale: 50 %
   :align: center
   :figwidth: 400px

   ARM Keil Microvision Logic Analyzer.
