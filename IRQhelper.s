 EXPORT DisableInterrupts
 EXPORT EnableInterrupts

        AREA    ||.text||, CODE, READONLY, ALIGN=3
        ARM
  PRESERVE8

DisableInterrupts PROC
      STMDB SP!, {R0}           ; Push R0
      MRS   R0, CPSR            ; Get CPSR.
      ORR   R0, R0, #0xC0       ; Disable IRQ, FIQ.
      MSR   CPSR_cxsf, R0       ; Write back modified value.
      LDMIA SP!, {R0}           ; Pop R0
      BX    LR                  ; return
      ENDP

EnableInterrupts PROC
      STMDB SP!, {R0-R1}        ; Push R0,R1
      MRS   R0, CPSR            ; Get CPSR.
      AND   R1, R0, #0x0000001f ; R1 = R0 & 0x1f (mode bits)
      CMP   R1, #0x00000012     ; Test for IRQ mode
      BICNE   R0, R0, #0x80     ; Enable IRQ, but not in IRQ-Mode (no nesting)
      MSR   CPSR_cxsf, R0       ; Write back modified value.
      LDMIA SP!, {R0-R1}        ; Pop R0,R1
      BX    LR                  ; return
      ENDP

      END                       ; End of file