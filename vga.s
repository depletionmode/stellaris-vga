  MODULE Timer0IntHandler
  PUBLIC Timer0IntHandler
  
  RSEG DATASEG : DATA (2)
  
Counter: dcd 0x00

  RSEG CODESEG : CODE (2)
  
  CODE16

Timer0IntHandler:
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
  
  ; *********
  ; ** hfp ** [40 cyces]
  ; *********
  ; prologue [3 cycles]
  push {r7, lr}
  
  ; save regs [5 cycles]
  push {r1, r2, r3, r4}
  
  ; clear interrupt timer [5 cycles]
  mov r1, #1             ; TIMER_TIMA_TIMEOUT
  ldr r0, =0x40030000    ; TIMER0_BASE
  str r1, [r0, #0x24]    ; *(TIMER0_BASE + TIMER_O_ICR) = TIMER_TIMA_TIMEOUT
  
  ; waste cycles [27 cycles]
  mov r0, #1
loop_0: ; [6*4=24 cycles]
  cmp r0, #6
  bneq loop_0
  
  ; ptr to GPIO_PORTB_BASE in r0 [2 cycles]
  ; (this will be persisted)
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  
  ; *********
  ; ** hsp ** [128 cycles]
  ; *********
  ; set hsp low [6 cycles]
  ldrb r1,[r0]
  mov r2, #0xfd
  and r1, r2
  str r1, [r0]  ; GPIO_PIN_1 clear
  
  ; load registers from ram (todo?)
 
  ; inc counter  [7 cycles]
  ldr r1, =Counter
  ldr r2, [r1]
  add r2, #1
  str r2, [r1]
  
  ; test counter for vsync on [5+9=14 cycles]
  ldr r2, =629
  cmp r2, r1
  beq vsync_on
  b cont_0
vsync_on:       ; [9 cycles]
  ; clear counter
  mov r2, #0
  str r2, [r1]
  ; vsync on (vsp low)
  ldrb r1,[r0]
  mov r2, #0xfe
  and r1, r2
  str r1, [r0]  ; GPIO_PIN_0 clear
cont_0: ; [9 cycles]
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  nop
  
  ; vsync off at line 4 [7+6=13 cycles]
  ldr r1, =Counter
  ldr r2, [r1]
  cmp r2, #4
  beq vsync_off
  b cont_1
vsync_off:      ; [6 cycles]
  ldrb r1,[r0]
  mov r2, #1
  orr r1, r2
  str r1, [r0]  ; GPIO_PIN_0 set
cont_1: ; [6 cycles]
  nop
  nop
  nop
  nop
  nop
  nop
  
  ; activate pixels on line 27
  ldr r0, =Counter
  ldr r1, [r0]
  cmp r1, #27
  beq activate_px
  b cont_2
activate_px:
  ldr r0,=0x40024000    ; GPIO_PORTE_BASE
  mov r1, #0xff         ; set entire port (for testing)
  str r1, [r0]
cont_2:
  nop
  nop
  nop
  nop
  nop
  
  ; deactivate piels on line 628
  ldr r0, =Counter
  ldr r1, [r0]
  ldr r2, =628
  cmp r1, r2
  beq deactivate_px
  b cont_3
deactivate_px:
  ldr r0,=0x40024000    ; GPIO_PORTE_BASE
  mov r1, #0x00         ; clear entire port (for testing)
  str r1, [r0]
cont_3:
  nop
  nop
  nop
  nop
  nop
  
  ; save registers to sram
  
  ; hsync off [8 cycles]
  ldr r0,=0x40005000    ; GPIO_PORTB_BASE
  ldrb r1,[r0]
  mov r2, #2
  orr r1, r2            ; GPIO_PIN_1 set
  str r1, [r0]
  
  ; ***
  ; hbp
  ; ***
  ; exit on vblank
  ldr r0, =Counter
  ldr r1, [r0]
  cmp r1, #0
  beq end
  ; else nops
  nop
  
  ; ***
  ; hpx [800 cycles]
  ; ***
  
  ldr r0,=0x40024000    ;2    ; GPIO_PORTE_BASE
  mov r4, #1            ;1
  
  ; 20 cycles / colour
  mov r2, #0    ;1
loop_1: ; [24*33=792 cycles]
  str r4, [r0]  ;2
  mov r1, #0    ;1
loop_2: ; [4*4=16 cycles]
  add r1, #1    ;1
  cmp r1, #4    ;1
  bneq loop_2   ;2
  add r4, #1    ;1
  add r2, #1    ;1
  cmp r2, #33   ;1
  bneq loop_1   ;2
  
  nop
  nop
  nop
  nop
  
  ; hblank
  ; clear rgbi port
  mov r1, #0
  str r1, [r0]

end:
  ; restore regs [5 cycles]
  pop {r1, r2, r3, r4}

  ; return from interrupt [4 cycles]
  pop {r0, pc}

  END