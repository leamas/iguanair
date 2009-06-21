;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: USBINT.asm
;;   Version: 1.5, Updated on 2008/6/23 at 12:26:41
;;  Generated by PSoC Designer 5.0.423.0
;;
;;  DESCRIPTION: USB Device User Module software implementation file
;;               for the enCoRe II family of devices
;;
;;  NOTE: User Module APIs conform to the fastcall convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API
;;        function returns. Even though these registers may be preserved now,
;;        there is no guarantee they will be preserved in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2004, 2005. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "USB_macros.inc"
include "USB.inc"

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------

AREA bss (RAM,REL)

;-----------------------------------------------
;  Constant Definitions
;-----------------------------------------------
;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------

AREA text (ROM, REL)
;-----------------------------------------------------------------------------
;  FUNCTION NAME: USB_EP1_ISR
;
;  DESCRIPTION:    Handle the Endpoint 1 event by updating the data toggle
;                  and setting the endpoint state to EVENT_PENDING.  The SIE
;                  automatically set the mode to NAK both IN and out transfers
;-----------------------------------------------------------------------------
export  USB_EP1_ISR
export _USB_EP1_ISR
 USB_EP1_ISR:
_USB_EP1_ISR:
   ;@PSoC_UserCode_BODY_EP1@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.
STD_EP1:    EQU     1   ; Set this equate to 0 to remove the standard
                        ; endpoint handling code
   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)

IF  STD_EP1
    PUSH A
    XOR     [USB_EPDataToggle], 2 ; Update EP1 data toggle
    MOV     A, REG[EP1MODE]            ; Get the mode
    MOV     [USB_EndpointAPIStatus+1], EVENT_PENDING ; For the API
    POP A
    RETI
ENDIF
;-----------------------------------------------------------------------------
;  FUNCTION NAME: USB_EP2_ISR
;
;  DESCRIPTION:    Handle the Endpoint 2 event by updating the data toggle
;                  and setting the endpoint state to EVENT_PENDING.  The SIE
;                  automatically set the mode to NAK both IN and out transfers
;-----------------------------------------------------------------------------
export  USB_EP2_ISR
export _USB_EP2_ISR
 USB_EP2_ISR:
_USB_EP2_ISR:
   ;@PSoC_UserCode_BODY_EP2@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.
STD_EP2:    EQU     1   ; Set this equate to 0 to remove the standard
                        ; endpoint handling code
   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)

IF  STD_EP2
    PUSH A
    XOR     [USB_EPDataToggle], 4 ; Update EP2 data toggle
    MOV     A, REG[EP2MODE]            ; Get the mode
    MOV     [USB_EndpointAPIStatus + 2], EVENT_PENDING ; For the API
    POP A
    RETI
ENDIF
;-----------------------------------------------------------------------------
;  FUNCTION NAME: USB_RESET_ISR
;
;  DESCRIPTION:    Handle the USB Bus Reset Interrupt
;-----------------------------------------------------------------------------
export  USB_RESET_ISR
export _USB_RESET_ISR
 USB_RESET_ISR:
_USB_RESET_ISR:

   ;@PSoC_UserCode_BODY_USB_RESET@ (Do not change this line.)
   ;---------------------------------------------------
   ; Insert your custom code below this banner
   ;---------------------------------------------------
   ;   NOTE: interrupt service routines must preserve
   ;   the values of the A and X CPU registers.

STD_USB_RESET:    EQU     1 ; Set this equate to 0 to remove the standard
                            ; USB reset handling code below

   ;---------------------------------------------------
   ; Insert your custom code above this banner
   ;---------------------------------------------------
   ;@PSoC_UserCode_END@ (Do not change this line.)

IF  STD_USB_RESET
    PUSH A
    PUSH X
    MOV     A, [USB_bCurrentDevice]     ; Select the current device
    LCALL   _USB_Start     ; Restart USB
    POP X
    POP A
ENDIF

    RETI
;-----------------------------------------------------------------------------
;  FUNCTION NAME: USB_ACT_ISR
;
;  DESCRIPTION:    Handle the activity ISR
;
;  THEORY of OPERATION or PROCEDURE:
;
;   The activity interrupt sets a RAM flag indicating activity and disables the
;   interrupt.  Disabling the interrupt keeps the bus activity from creating too
;   many interrupts.  bCheckActivity checks and clears the flag, the enables
;   interrupts for the next interval.
;
;-----------------------------------------------------------------------------
export  USB_ACT_ISR
export _USB_ACT_ISR
 USB_ACT_ISR:
_USB_ACT_ISR:
    MOV    [USB_bActivity], 1          ; Set the activity flag
    M8C_DisableIntMask INT_MSK1, INT_MSK1_USB_ACTIVITY
    RETI
; End of File USB_std.asm
