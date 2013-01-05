  MODULE Timer0IntHandler
  PUBLIC Timer0IntHandler
  
  RSEG DATASEG : DATA (2)
  
Counter: dcd 0x00

  RSEG CODESEG : CODE (2)
  
  CODE16

Timer0IntHandler:
  push {r7, lr}
  
  ; save regs
  push {r0}
  push {r1}
  push {r2}
  
  ; clear interrupt timer
  ;movs r1, #1
  ldr r1,=1             ; TIMER_TIMA_TIMEOUT
  ldr r0,=0x40030000    ; TIMER0_BASE
  str r1,[r0, #0x24]    ; *(TIMER0_BASE + TIMER_O_ICR) = TIMER_TIMA_TIMEOUT

  ; horizontal timing
  ; hfp 40 (1-40)
  ; hsp 128 (41-168)
  ; hbp 88 (169-256)
  ; hpx 800 (257-1056)
  ; total = 1056
  
  ; vertical timing
  ; vsp 4 (1-4)
  ; vbp 23 (5-27)
  ; vln 600 (28-627)
  ; vfp 1 (628)
  ; total = 628
 
  ; inc counter
  ldr r0, =Counter
  ldr r1, [r0]
  add r1, #1
  str r1, [r0]
  ; sync interrupt latency to hfp
  
  ; hsp and vsp
  ; set hsp low
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  ldrb r1,[r0];
  mov r2, #0xfd
  and r1, r2            ; GPIO_PIN_1 clear
  str r1, [r0]
  
  ; load registers from ram
  
  ; vsync on (vsp low)
  ; set vsp low
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  ldrb r1,[r0];
  mov r2, #0xfe
  and r1, r2            ; GPIO_PIN_0 clear
  str r1, [r0]
  
  ; vsync off at line 4
  ldr r0, =Counter
  ldr r1, [r0]
  cmp r1, #4
  beq vsync_off
  b cont_1
vsync_off:
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  ldrb r1,[r0];
  mov r2, #1
  orr r1, r2            ; GPIO_PIN_0 set
  str r1, [r0]
cont_1:
  nop
  nop
  nop
  nop
  nop
  
  ; activate pixels on line 27
  
  ; deactivate piels on line 628
  
  ; save registers to sram
  
  ; hsync off
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  ldrb r1,[r0];
  mov r2, #2
  orr r1, r2            ; GPIO_PIN_1 set
  str r1, [r0]
  
  ; ***
  ; hbp
  ; ***
  ; exit on vblank
  ; else nops
  
  ; ***
  ; hpx
  ; ***
  
  ; can output color on every cycle (each cycle is a pixel)
  ; nops between pixel change
  
  ; hblank
  ; clear rgbi port
  
  ; restore regs
  pop {r2}
  pop {r1}
  pop {r0}

  ; return from interrupt
  pop {r0, pc}

  END