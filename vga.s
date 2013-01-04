  MODULE Timer0IntHandler
  PUBLIC Timer0IntHandler

  RSEG CODESEG : CODE (2)
  
  CODE16

Timer0IntHandler:
  ; r12 is used as a counter (make sure not using in main code)
  ; clear interrupt timer

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
  
  ; todo save regs
  ;push r1
  ;push r2
  
  ; sync interrupt latency to hfp
  
  ; hsp and vsp
  ; set hsp low
  ; load registers from ram
  
  ; vsync on (vsp low)
  ; set vsp low
  
  ; vsync off at line 4
  
  ; activate pixels on line 27
  
  ; deactivate piels on line 628
  
  ; save registers to sram
  
  ; hsync off
  ; set hsp high
  
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
  
  ; resore regs
  ;pop r2
  ;pop r1
  
  ;return from interrupt
  
  nop

  END