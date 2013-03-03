  .file "vga.S"

  .data
  .align 2
  .globl LineCount
LineCount: .word 0

  .text
  .align 2
  .globl Timer0IntHandler
  .type Timer0IntHandler, %function

Timer0IntHandler:
  @ horizontal timing
  @ hfp 40 (1-40)
  @ hsp 128 (41-168)
  @ hbp 88 (169-256)
  @ hpx 800 (257-1056)
  @ total = 1056
  
  @ vertical timing
  @ vsp 4 (1-4)
  @ vbp 23 (5-27)
  @ vln 600 (28-627)
  @ vfp 1 (628)
  @ total = 628
  
  @ *********
  @ ** hfp ** [40 cycles]
  @ *********
  @ prologue [3 cycles]
  push {r3, lr}
 
  @ save regs [5 cycles]
  push {r1, r2, r3, r4}
  
  @ clear interrupt timer [5 cycles]
  mov r1, #1             @ TIMER_TIMA_TIMEOUT
  ldr r0, =0x40030000    @ TIMER0_BASE
  str r1, [r0, #0x24]    @ *(TIMER0_BASE + TIMER_O_ICR) = TIMER_TIMA_TIMEOUT
 
  @ ptr to GPIO_PORTB_BASE in r0 [2 cycles]
  @ (this will be persisted)
  ldr r0,=0x40005000    @ GPIO_PORTB_BASE
  
  @ waste cycles [25 cycles]
  mov r0, #0
loop_0: @ {6*4=24 cycles}
  add r0, #1
  cmp r0, #6
  bne loop_0 @2
  
  @ *********
  @ ** hsp ** [128 cycles]
  @ *********
  @ set hsp low [6 cycles]
  ldrb r1,[r0]
  mov r2, #0xfd
  and r1, r2
  str r1, [r0]  @ GPIO_PIN_1 clear
  
  @ inc line counter  [7 cycles]
  ldr r1, =LineCount
  ldr r2, [r1]
  add r2, #1
  str r2, [r1]
  
  @ vsync on at line 1 [9 cycles]
  cmp r2, #1    @ now at start of vsp
  beq .Lvsync_on
  nop
  nop
  nop
  nop
  b .Lcont_0
.Lvsync_on:     @ {6 cycles}
  ldrb r1,[r0]
  mov r2, #0xfe
  and r1, r2
  str r1, [r0]  @ GPIO_PIN_0 clear
.Lcont_0:
 
  @ vsync off at line 5 [13 cycles]
  ldr r1, =LineCount
  ldr r2, [r1]
  cmp r2, #5
  beq .Lvsync_off
  nop
  nop
  nop
  nop
  b .Lcont_1
.Lvsync_off:    @ {6 cycles}
  ldrb r1,[r0]
  mov r2, #1
  orr r1, r2
  str r1, [r0]  @ GPIO_PIN_0 set
.Lcont_1:
  
  @ activate pixels on line 28 [12 cycles]
  ldr r1, =LineCount
  ldr r2, [r1]
  cmp r2, #28
  beq .Lactivate_px
  nop
  nop
  nop
  b .Lcont_2
.Lactivate_px:  @ {5 cycles}
  ldr r0,=0x40024000    @ GPIO_PORTE_BASE
  mov r1, #0xff         @ set entire port (for testing)
  str r1, [r0]
.Lcont_2:
  
  @ deactivate pixels on line 628 [14 cycles]
  ldr r1, =LineCount
  ldr r2, [r1]
  ldr r1, =628
  cmp r2, r1
  beq .Ldeactivate_px
  nop
  nop
  nop
  b .Lcont_3
.Ldeactivate_px: @{5 cycles}
  ldr r0,=0x40024000    @ GPIO_PORTE_BASE
  mov r1, #0x00         @ clear entire port (for testing)
  str r1, [r0]
.Lcont_3:

  @ waste cycles [59 cycles] 
  mov r0, #0
.Lwasteloop_1:  @ {14*4=56 cycles}
  add r0, #1
  cmp r0, #14
  bne .Lwasteloop_1 @2
  nop
  nop

  @ hsync off [8 cycles]
  ldr r0,=0x40005000    @ GPIO_PORTB_BASE
  ldrb r1,[r0]
  mov r2, #2
  orr r1, r2            @ GPIO_PIN_1 set
  str r1, [r0]
  
  @ *********
  @ ** hbp ** [88 cycles]
  @ *********
  @ exit on vblank [7 cycles]
  ldr r1, =LineCount
  ldr r2, [r1]
  cmp r2, #1
  beq end
  
  @ waste cycles [77 cycles]
  mov r1, #0
.Lwasteloop_2:  @ {19*4=76 cycles}
  add r1, #1
  cmp r1, #19
  bne .Lwasteloop_2
  
  @ set up pixel port [3 cycles]
  ldr r0,=0x40024000    @ GPIO_PORTE_BASE
  mov r1, #0

  @ set up color counter [1 cycle]
  mov r4, #0

  @ *********
  @ ** hpx ** [800 cycles]
  @ *********

  @ output pattern [800 cycles]
.Lcolor_loop:
  str r1, [r0]
  add r1, #1
  add r4, #1
  cmp r4, #100
  nop
  bne .Lcolor_loop
  
  @ hblank
  @ clear rgbi port
  mov r1, #0
  str r1, [r0]

end:
  @ restore regs [5 cycles]
  pop {r1, r2, r3, r4}
  
  @ return from interrupt [4 cycles]
  pop {r3, pc}
  @.word 0x40030000 @addmi r0, r3, r0

