		AREA project, CODE, READONLY
FIO0DIR         EQU 0x3FFFC000
FIO0SET         EQU 0x3FFFC018
FIO0CLR         EQU 0x3FFFC01C
FIO1DIR         EQU 0x3FFFC020
FIO1SET         EQU 0x3FFFC038
FIO1CLR         EQU 0x3FFFC03C
	
PINSEL0         EQU 0xE002C000
PINSEL1         EQU 0xE002C004

PWMIR           EQU 0xE0014000
PWMTCR          EQU 0xE0014004
PWMTC           EQU 0xE0014008
PWMPR           EQU 0xE001400C
PWMPC           EQU 0xE0014010
PWMMCR          EQU 0xE0014014
PWMMR0          EQU 0xE0014018
PWMMR4          EQU 0xE0014040
PWMMR5			EQU 0xE0014044
PWMPCR			EQU 0xE001404C
PWMLER			EQU 0xE0014050

VICIntSelect    EQU 0xFFFFF00C
VICIntEnable    EQU 0xFFFFF010
VICVectAddr     EQU 0xFFFFF030
VICVectAddr0    EQU 0xFFFFF100
VICVectCntl0    EQU 0xFFFFF200

HSYNC			EQU	0x00200000
VSYNC			EQU	0x00400000
RED				EQU 0x00020000
GREEN			EQU	0x00040000
BLUE			EQU	0x00080000

RGB				EQU 0x000E0000

; VSYNC signal values
P_START 		EQU 0x1
; 11 lines for FRONT PORCH
S_START 		EQU 0xC
; 2 lines for SYNC WIDTH
B_START 		EQU 0xE
; 31 lines for BACK PORCH
V_START 		EQU 0x202
; 480 lines for ACTIVE VIDEO
V_END   		EQU 0x210
	
HFREQ			EQU 0x477				; Horz sync frequency
HSYNW			EQU 0x71				; Horz sync width
HSYOFW			EQU (HFREQ-HSYNW)		; freq - sync width

;macro to set sync signals direction
		MACRO
$label		SET_SYNC_DIR
			LDR		R4, 	=FIO0DIR
			LDR		R5, 	=VSYNC
			STR		R5,		[R4]
		MEND
;macro to set RGB signal direction
		MACRO
$label		SET_RGB_DIR
			LDR		R4, 	=FIO1DIR
			LDR		R5,		=RGB
			STR		R5, 	[R4]
		MEND
;macro to clear VSYNC pin
		MACRO
$label		CLR_VSYNC
			LDR		R4, 	=FIO0CLR
			LDR		R5,		=VSYNC
			STR		R5, 	[R4]
		MEND
;macro to set VSYNC pin
		MACRO
$label		SET_VSYNC
			LDR		R4, 	=FIO0SET
			LDR		R5,		=VSYNC
			STR		R5, 	[R4]
		MEND
;macro to clear RGB pins
		MACRO
$label		CLR_RGB
			LDR		R4, 	=FIO1CLR
			LDR		R5,		=RGB
			STR		R5, 	[R4]
		MEND
;macro to set RGB pins
		MACRO
$label		SET_RGB
			LDR		R4, 	=FIO1SET
			LDR		R5,		=RGB
			STR		R5, 	[R4]
		MEND
;macro to set SFR $register to $value
		MACRO
$label		SET_REG $register,$value
			LDR R4, $register
			LDR R5, $value
			STR R5, [R4]
		MEND
		MACRO
$label		DJNZ	$register, $target, $value
$label		SUBS $register, $register, $value
			BNE $target
		MEND
		
		EXPORT display
		EXPORT initVGA
		EXTERN Mode_USR
display	PROC
		;start PWM
		SET_REG =PWMTCR,=0x00000009
		LDR R2, =0x00009600
nxchar	LDR R3, =0x00000020
nxbit	LDR R1, [R0]
		SUB R5, R5, R3
		AND R4, R3, #0x1
		DJNZ R3, nxbit, #1
		ADD R1, R1, #4
		DJNZ R2, nxchar, #1
		B	display
		ENDP

initVGA	PROC
		LDR R6,=P_START
		SET_SYNC_DIR
		SET_RGB_DIR
setupHsync ;31.25 KHz
		;set GPIOs for PWM4
		SET_REG =PINSEL0,=0x00030000
		;set GPIOs for PWM5 - HSYNC
		SET_REG =PINSEL1,=0x00000C00
		
		;PWMPR = 0
		SET_REG =PWMPR,=0x00000002
		;31.77KHz line frequency
		SET_REG =PWMMR0,=HFREQ
		;PWM5 match value
		SET_REG =PWMMR5,=HSYOFW
		
		;reset and interrupt on MR0
		SET_REG =PWMMCR,=0x00000003

		;SET_REG =PWMMR4,=HFREQ
		
		;latch MR0, MR5
		SET_REG =PWMLER,=0x00000021
		;PWM5 enable
		SET_REG =PWMPCR,=0x00002000
		
		;PWM+counter reset
		SET_REG =PWMTCR,=0x00000002
		;set PWM interrupt as IRQ
		SET_REG =VICIntSelect,=0x00000000
		;load interrupt vector
		SET_REG =VICVectAddr0,=vsync_IRQ_handler
		;slot 8, IRQ enable
		SET_REG =VICVectCntl0,=0x00000028
		;enable PWM interrupt
		SET_REG =VICIntEnable,=0x00000100 
		BX LR
		ENDP

;ISR for vsync
vsync_IRQ_handler ; called after every line
set		CMP 		R6, 	#S_START
		BNE 		clear
		CLR_VSYNC
		B 			break
clear	CMP 		R6,		#B_START
		BNE 		reset
		SET_VSYNC
		B 			break
reset	CMP 		R6, 	#V_END
		BNE			break
		LDR R6, 	=0x00000000
break	
		;increment vsync state
		ADD R6, 	R6, 	#0x1
		;acknowledge interrupt
		SET_REG 	=VICVectAddr,=0x00000000
		; clear flag since only PWMMR0 interrupt is used, immediate write wo read
		SET_REG		=PWMIR,=0x00000001
		MSR CPSR_c , #Mode_USR
		SUB LR, 	LR, 	#4
		BX 	LR
		END