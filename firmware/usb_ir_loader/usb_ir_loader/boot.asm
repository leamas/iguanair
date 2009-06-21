; Generated by PSoC Designer 5.0.423.0
;
;@Id: boot.tpl#876 @
;=============================================================================
;  FILENAME:   boot.asm
;  VERSION:    4.08
;  DATE:       28 June 2007
;
;  DESCRIPTION:
;  M8C Boot Code for CY7C63800 microcontroller family.
;  This file also contains the Interrupt Service Routines for enCoRe II GPIO
;  interrupts: INT0, INT1, INT2, as well as the GPIO Port interrupts for
;  port 0, port 1, port 2, and port 3.
;
;  Copyright (C) Cypress Semiconductor 2004, 2005. All rights reserved.
;
; NOTES:
; PSoC Designer's Device Editor uses a template file, BOOT.TPL, located in
; the project's root directory to create BOOT.ASM. Any changes made to 
; BOOT.ASM will be  overwritten every time the project is generated; therefore
; changes should be made to BOOT.TPL not BOOT.ASM. Care must be taken when
; modifying BOOT.TPL so that replacement strings (such as @PROJECT_NAME)
; are not accidentally modified.
;
;=============================================================================

include ".\lib\GlobalParams.inc"	;File generated by PSoC Designer (Project dependent)
include "m8c.inc"			;Part specific file
include "m8ssc.inc"			;Part specific file
include "memory.inc"			;File generated by PSoC Designer (Project dependent) 
include "loader.inc"

;-----------------------------------------------------------------------------
; Optimization flags
;-----------------------------------------------------------------------------
C_LANGUAGE_SUPPORT: equ 0   ;Set to 0 to optimize for ASM only

;-----------------------------------------------------------------------------
; Export Declarations
;-----------------------------------------------------------------------------

export __Start
IF	(TOOLCHAIN & HITECH)
ELSE
export __Exit
export __bss_start

export __lit_start
export __idata_start
export __data_start
export __func_lit_start
export __text_start
export __usermodules_start
export __psoc_config_start
ENDIF

;-----------------------------------------------------------------------------
; Interrupt Vector Table
;-----------------------------------------------------------------------------
;
; Interrupt vector table entries are 4 bytes long and contain the code that
; services the interrupt (or causes it to be serviced).
;
;-----------------------------------------------------------------------------
; interrupt vector cannot move, but everything else can be moved up in memory
    AREA    TOP(ROM,ABS,CON)

    org 0                   ;Reset Interrupt Vector
IF	(TOOLCHAIN & HITECH)
;   jmp   __Start                  ;C compiler fills in this vector
ELSE
    jmp   __Start                  ;First instruction executed following a Reset
ENDIF

    org 04h                 ;Supply Monitor Interrupt Vector
    halt                    ;Stop execution if power falls too low

    org 08h                 ;INT0 Interrupt Vector
    ljmp    INT0_ISR
    reti

    org 0Ch                 ;SPI TX Empty Interrupt Vector
    // call	void_handler
    reti

    org 10h                 ;SPI RX Full Interrupt Vector
    // call	void_handler
    reti

    org 14h                 ;GPIO Port 0 Interrupt Vector
    ljmp    PORT0_ISR
    reti
    
    org 18h                 ;GPIO Port 1 Interrupt Vector
    ljmp    PORT1_ISR
    reti
    
    org 1Ch                 ;INT1 Interrupt Vector
    ljmp    INT1_ISR
    reti
    
    org 20h                 ;USB Endpoint 0 Interrupt Vector
    ljmp	_USB_EP0_ISR
    reti

    org 24h                 ;USB Endpoint 1 Interrupt Vector
    ljmp	_USB_EP1_ISR
    reti

    org 28h                 ;USB Endpoint 2 Interrupt Vector
    ljmp	_USB_EP2_ISR
    reti

    org 2Ch                 ;USB Bus Reset Interrupt Vector
    ljmp	_USB_RESET_ISR
    reti

    org 30h                 ;USB Bus Activity Interrupt Vector
    ljmp	_USB_ACT_ISR
    reti

    org 34h                 ;One Millisecond Interval Timer Interrupt Vector
    // call	void_handler
    reti

    org 38h                 ;Programmable Interval Timer Interrupt Vector
    // call	void_handler
    reti

    org 3Ch                 ;Timer Capture 0 Interrupt Vector
    ljmp body_tcap_int
    reti
	
    org 40h                 ;Timer Capture 1 Interrupt Vector
    // call	void_handler
    reti

    org 44h                 ;Free Running Counter Wrap Interrupt Vector
    ljmp body_twrap_int
    reti

    org 48h                 ;INT 2 Interrupt Vector
    ljmp    INT2_ISR
    reti

    org 4Ch                 ;PS2 Data Low
    // call	void_handler
    reti

    org 50h                 ;GPIO Port 2 Interrupt Vector
    ljmp    PORT2_ISR
    reti

    org 54h                 ;GPIO Port 3 Interrupt Vector
    ljmp    PORT3_ISR
    reti

    org 58h                 ;Reserved
    // call	void_handler
    reti

    org 5Ch                 ;Reserved
    // call	void_handler
    reti

    org 60h                 ;Reserved
    // call	void_handler
    reti

    org 64h                 ;Sleep Timer Interrupt Vector
    // call	void_handler
    reti

;-----------------------------------------------------------------------------
;  Start of Execution
;  CPU is operating at 3 MHz, change to 12 MHz
;  IO Bank is Bank0
;-----------------------------------------------------------------------------

IF	(TOOLCHAIN & HITECH)
 	AREA PD_startup(CODE, REL, CON)
ELSE
    org 68h
ENDIF
__Start:

IF ( WATCHDOG_ENABLE )             ; WDT selected in Global Params
    M8C_EnableWatchDog
ENDIF
    ;------------------
    ; Set up the clocks
    ;------------------

    ; Configure the Clock Out
    OR   REG[CLKIOCR], (CLOCK_OUT_JUST)

    mov  [bSSC_KEY1],0             ; Lockout Flash and Supervisiory operations
    mov  [bSSC_KEYSP],0      

IF	(TOOLCHAIN & HITECH)
    ;---------------------------
    ; Set up the Temporary stack
    ;---------------------------
    ; A temporary stack is set up for the SSC instructions.
    ; The real stack start will be assigned later.
    ;
	global		__Lstackps
	mov     a,low __Lstackps
	swap    a,sp
ELSE
    ;------------------
    ; Set up the stack
    ;------------------
    mov   A, __ramareas_end        ; Set top of stack to end of used RAM
    swap  SP, A                    ; This is only temporary if going to LMM
ENDIF

    ;-------------------------------------------------------------------------
    ; All the user selections and UserModule selections are now loaded,
    ; except CPU frequency (CPU is runing at 12 MHz).  Load the PSoC 
    ; configuration with a 12 MHz CPU clock to keep config time short.
    ;-------------------------------------------------------------------------
    lcall LoadConfigInit           ; Configure PSoC blocks per Dev Editor

IF	(TOOLCHAIN & HITECH)
; The C compiler will customize the startup code - it's not required here

ELSE
IF (C_LANGUAGE_SUPPORT)
    call InitCRunTime              ; Initialize for C language
ENDIF ;(C_LANGUAGE_SUPPORT)
ENDIF

    ;-------------------------------------------------------------------------
    ; Global Interrupt are NOT enabled, this should be done in main().
    ; LVD is set but will not occur unless Global Interrupts are enabled. 
    ; Global Interrupts should be as soon as possible in main().
    ;-------------------------------------------------------------------------
    mov  reg[INT_VC],0              ; Clear any pending interrupts which may
                                    ; have been set during the boot process. 
IF	(TOOLCHAIN & HITECH)
	ljmp  startup                  ; Jump to C compiler startup code
ELSE
    lcall _main                     ; Call main

__Exit:
    jmp  __Exit                     ; Wait here till power is turned off
ENDIF ; TOOLCHAIN



;-----------------------------------------------------------------------------
; C Runtime Environment Initialization
; The following code is conditionally assembled.
;-----------------------------------------------------------------------------
IF (TOOLCHAIN & IMAGECRAFT)
IF (C_LANGUAGE_SUPPORT)

InitCRunTime:
    ;-----------------------------
    ; clear bss segment
    ;-----------------------------
    mov  A,0
    mov  [__r0],<__bss_start
BssLoop:
    cmp  [__r0],<__bss_end
    jz   BssDone
    mvi  [__r0],A
    jmp  BssLoop
BssDone:
    ;----------------------------
    ; copy idata to data segment
    ;----------------------------
    mov  A,>__idata_start
    mov  X,<__idata_start
    mov  [__r0],<__data_start
IDataLoop:
    cmp  [__r0],<__data_end
    jz   IDataDone
    push A
    romx
    mvi  [__r0],A
    pop  A
    inc  X
    adc  A,0
    jmp  IDataLoop
IDataDone:
    ret

ENDIF ;(C_LANGUAGE_SUPPORT)
ENDIF ;(TOOLCHAIN)
IF	(TOOLCHAIN & HITECH)
ELSE
;-----------------------------------------------------------------------------
; RAM segments for C CONST, static & global items
;-----------------------------------------------------------------------------
    AREA lit
__lit_start:

    AREA idata
__idata_start:

    AREA func_lit
__func_lit_start:

    AREA psoc_config(ROM,REL,CON)
__psoc_config_start:

    AREA UserModules(ROM,REL,CON)
__usermodules_start:

    AREA gpio_isr(ROM,REL,CON)
__gpio_isr_start:

;---------------------------------------------
;         CODE segment for general use
;---------------------------------------------
    AREA text(ROM,REL,CON)
__text_start:

;---------------------------------------------
;         Begin RAM area usage
;---------------------------------------------
    AREA data              (RAM, REL, CON)   ; initialized RAM
__data_start:

    AREA virtual_registers (RAM, REL, CON)   ; Temp vars of C compiler
    AREA InterruptRAM      (RAM, REL, CON)   ; Interrupts, on Page 0
    AREA bss               (RAM, REL, CON)   ; general use
__bss_start:
ENDIF ; TOOLCHAIN
;-----------------------------------------------------------------------------
; End of the boot code
;-----------------------------------------------------------------------------

;-----------------------------------------------------------------------------
; GPIO Interrupt Service Routines
;-----------------------------------------------------------------------------
 AREA gpio_isr(ROM,REL,CON)
;-----------------------------------------------------------------------------
;  FUNCTION NAME: INT0_ISR
;
;  DESCRIPTION:   This is the ISR for the the INT0 GPIO interrupt
;
;-----------------------------------------------------------------------------
INT0_ISR:
   ;@PSoC_UserCode_BODY_1@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: INT1_ISR
;
;  DESCRIPTION:   This is the ISR for the the INT1 GPIO interrupt
;
;-----------------------------------------------------------------------------
INT1_ISR:
   ;@PSoC_UserCode_BODY_2@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: INT2_ISR
;
;  DESCRIPTION:   This is the ISR for the the INT2 GPIO interrupt
;
;-----------------------------------------------------------------------------
INT2_ISR:
   ;@PSoC_UserCode_BODY_3@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PORT0_ISR
;
;  DESCRIPTION:   This is the ISR for the the PORT0 GPIO interrupt
;                 Note: Interrupts for GPIO P0.2, P0.3, and P0.4 are
;                 not dispatched through this ISR.  Those interrupts
;                 are dipatched through INT0, INT1 and INT2 respectively.
;
;-----------------------------------------------------------------------------
PORT0_ISR:
   ;@PSoC_UserCode_BODY_4@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PORT1_ISR
;
;  DESCRIPTION:   This is the ISR for the the PORT1 GPIO interrupt
;
;-----------------------------------------------------------------------------
PORT1_ISR:
   ;@PSoC_UserCode_BODY_5@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PORT2_ISR
;
;  DESCRIPTION:   This is the ISR for the the PORT2 GPIO interrupt
;
;-----------------------------------------------------------------------------
PORT2_ISR:
   ;@PSoC_UserCode_BODY_5@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: PORT3_ISR
;
;  DESCRIPTION:   This is the ISR for the the PORT3 GPIO interrupt
;
;-----------------------------------------------------------------------------
PORT3_ISR:
   ;@PSoC_UserCode_BODY_6@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)
   RETI
;-----------------------------------------------------------------------------
; End GPIO Interrupt Service Routines
;-----------------------------------------------------------------------------
;end of file
