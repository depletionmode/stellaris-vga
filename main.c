#include "inc/hw_ints.h"
#include "inc/hw_memmap.h"
#include "inc/hw_types.h"
#include "driverlib/debug.h"
#include "driverlib/fpu.h"
#include "driverlib/gpio.h"
#include "driverlib/interrupt.h"
#include "driverlib/pin_map.h"
#include "driverlib/rom.h"
#include "driverlib/sysctl.h"
#include "driverlib/timer.h"
#include "utils/uartstdio.h"
/*
void Timer0IntHandler()
{
  TimerIntClear(TIMER0_BASE, TIMER_TIMA_TIMEOUT);
  // TIMER0_BASE 0x40030000
  // TIMER_TIMA_TIMEOUT 0x00000001
  // TIMER_O_ICR 0x00000024

  // update this reg 0x40030024 = 0x00000001

  asm("nop");
}*/

void main()
{
  /* run at 40 mhz */
  SysCtlClockSet(SYSCTL_SYSDIV_5 |
                 SYSCTL_USE_PLL |
                 SYSCTL_OSC_MAIN |
                 SYSCTL_XTAL_16MHZ);
  
  /* enable & configure timer + interrupt*/
  SysCtlPeripheralEnable(SYSCTL_PERIPH_TIMER0);
  IntMasterEnable();
  TimerConfigure(TIMER0_BASE, TIMER_CFG_PERIODIC);
  TimerLoadSet(TIMER0_BASE,
               TIMER_A,
               (unsigned int)(SysCtlClockGet() / 1000 / 1000 * 26.4));     /* 26.4us (1056 cycles @ 40 mhz) */
  IntEnable(INT_TIMER0A);
  TimerIntEnable(TIMER0_BASE, TIMER_TIMA_TIMEOUT);
  TimerEnable(TIMER0_BASE, TIMER_A);
  
  /* enable led */
  SysCtlPeripheralEnable(SYSCTL_PERIPH_GPIOF);
  GPIOPinTypeGPIOOutput(GPIO_PORTF_BASE, GPIO_PIN_1);
  
  while (1)
  {
    /* blink led */
    int i = 0xffff;
    
    while (i--);
    
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, 1);
    SysCtlDelay(SysCtlClockGet() / 1000);
    GPIOPinWrite(GPIO_PORTF_BASE, GPIO_PIN_1, 0);
  }
}