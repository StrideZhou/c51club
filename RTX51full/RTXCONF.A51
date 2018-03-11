$TITLE ('RTX-51 CONFIGURATION')
$SYMBOLS
$NOXREF
$NOCOND
$NOMOD51
$NORB
$PAGELENGTH(80) PAGEWIDTH(110)
;************************************************************************
;*                                                                      *
;*    R T X - 5 1  :  Configuration data for RTX-51 V 5.x               *
;*                                                                      *
;*----------------------------------------------------------------------*
;*                                                                      *
;*    Filename     :   RTXCONF.A51                                      *
;*    Language     :   Keil A-51                                        *
;*    Dev. system  :   IBM PC                                           *
;*    Targetsystem :   Any system based upon 8051 up                    *
;*                                                                      *
;*    Date:             9-MAY-1996                                      *
;*                                                                      *
;*    Purpose      :   - Defines the processor specific data            *
;*                       definitions for all supported processors.      *
;*                       New processor types may be easily added.       *
;*                     - Defines all user configurable system values.   *
;*                                                                      *
;*----------------------------------------------------------------------*
;* Rev. | Released    | Programmer  | Comments                          *
;*----------------------------------------------------------------------*
;* 0.1  |  4-APR-1991 | ThF         | First Version                     *
;* 5.00 |  3-NOV-1994 | EG          | Release V 5.00                    *
;* 5.01 |  7-SEP-1995 |             | Avoid L51 msg "empty segments",   *
;*      |             |             | few INT_EN_MASK_NUMBER's corrected*
;* 5.10 |  9-MAY-1996 |             | T2 support for CPU=2,5,13,14,16,17*
;*      |             |             | Add ?RTX_IDLE_FUNC                *
;* 5.10 | 26-MAY-1997 |             | Type 21(C515C) implemented        *
;* 5.10 | 22-JUL-2017 | Stride      | Delete useless cpu type           *
;*      |             |             | Type 150(STC15) implemented       *
;* 5.10 | 11-MAR-2018 | Stride      | Type 80(STC8) implemented         *
;************************************************************************
;*    (c) METTLER  &  FUCHS  AG,  LOEWENSTRASSE 21,  CH-8953 Dietikon   *
;*    Tel. (+41) (1) 740 41 00  /  Fax  (+41) (1) 740 15 67             *
;************************************************************************

;*----------------------------------------------------------------------*
;*
;*  USER CONFIGURABLE SYSTEM VALUES
;*
;*  All configurable values are contained in include file RTXSETUP.DCL
;*  (for details see the program documentation).
;*----------------------------------------------------------------------*

$INCLUDE(RTXSETUP.DCL)

;========================================================================
;  END OF USER-CONFIGURABLE SECTION
;========================================================================


$EJECT
;************************************************************************
;*                                                                      *
;*  THE FOLLOWING SECTIONS MUST NORMALLY NOT BE ALTERED BY THE USER     *
;*  ---------------------------------------------------------------     *
;*                                                                      *
;************************************************************************

NAME  ?RTX?CONFIGURATION      ; Do NOT alter the modulename !

;*----------------------------------------------------------------------*
;*  IMPORTS
;*----------------------------------------------------------------------*

EXTRN BIT    (?RTX_ENA_INT_REG1, ?RTX_ENA_INT_REG2)     ; from RTXDATA
EXTRN CODE   (?RTX_SYSCLK_INTHNDLR)                     ; from RTXCLK
EXTRN CODE   (?RTX_INT_HANDLER)                         ; from RTXINT
EXTRN DATA   (?RTX_TMP1)                                ; from RTXDATA

IF (?RTX_BANKSWITCHING = 1)
   EXTRN DATA     (?B_CURRENTBANK)                      ; from L51_BANK
   EXTRN NUMBER   (?B_MASK, ?B_FACTOR)                  ; from L51_BANK
   EXTRN CODE     (_SWITCHBANK)                         ; from L51_BANK
ENDIF

;*----------------------------------------------------------------------*
;*  EXPORTS
;*----------------------------------------------------------------------*

; System constants
PUBLIC   ?RTX_EXTRENTSIZE, ?RTX_EXTSTKSIZE, ?RTX_INTSTKSIZE
PUBLIC   ?RTX_TIMESHARING, ?RTX_BANKSWITCHING, ?RTX_INTREGSIZE
PUBLIC   ?RTX_MAILBOX_SUPPORT, ?RTX_SEMAPHORE_SUPPORT

; Initial Interrupt mask values
PUBLIC   ?RTX_IE_INIT, ?RTX_IEN1_INIT, ?RTX_IEN2_INIT

; Enable the interrupt enable registers for the selected processor
PUBLIC   ?RTX_INIT_INT_REG_FLAGS

; Interrupt number to enable-mask table
PUBLIC   ?RTX_INT_TO_BIT_TABLE_BASE

; Greatest interrupt number
PUBLIC   ?RTX_MAX_INT_NBR

; Processor specific interrupt enable masks
PUBLIC   ?RTX_IE, ?RTX_IEN1, ?RTX_IEN2

; Interrupt mask variables
PUBLIC   ?RTX_NM_IE, ?RTX_D_IE, ?RTX_ND_IE
PUBLIC   ?RTX_NM_IE1, ?RTX_D_IE1, ?RTX_ND_IE1
PUBLIC   ?RTX_NM_IE2, ?RTX_D_IE2, ?RTX_ND_IE2

; System Timer constants
PUBLIC   ?RTX_CLK_INT_NBR                       ; EQUATE
PUBLIC   ?RTX_TLOW, ?RTX_THIGH, ?RTX_TMOD       ; DATA
PUBLIC   ?RTX_TCON                              ; DATA
PUBLIC   ?RTX_TFLAG, ?RTX_TCONTROL              ; BIT
PUBLIC   ?RTX_TMOD_AND_MASK, ?RTX_TMOD_OR_MASK  ; EQUATES
PUBLIC   ?RTX_TCON_AND_MASK, ?RTX_TCON_OR_MASK  ; EQUATES

; Bank-Switching Support
PUBLIC   ?RTX_SWITCHBANK                        ; CODE
PUBLIC   ?RTX_SAVE_INT_BANK                     ; DATA
IF (?RTX_BANKSWITCHING = 0)
   PUBLIC   ?B_CURRENTBANK                      ; Dummy DATA-Definition
ENDIF

; Idle function
PUBLIC  ?RTX_IDLE_FUNC

; Mailbox and semaphore FIFO space
PUBLIC  ?RTX_MBX_PAGE
PUBLIC  ?RTX_MBX_PAGE_END
PUBLIC  ?RTX_SEM_PAGE
PUBLIC  ?RTX_SEM_PAGE_END


;*----------------------------------------------------------------------*
;*  MACROS
;*----------------------------------------------------------------------*

; This MACRO generates an RTX-51 interrupt entry point using the base 
; address ?RTX_INTBASE.

INT_ENTRY       MACRO   NO
EXTRN XDATA (?RTX_INT&NO&_TID)
PUBLIC          INT&NO&_VECTOR
                CSEG AT(?RTX_INTBASE+3+(&NO&*8))
INT&NO&_VECTOR: MOV     ?RTX_TMP1, A             ; Save A
                MOV     A, #LOW(?RTX_INT&NO&_TID); Set up ptr to int. TID
                LJMP    ?RTX_INT_HANDLER         ; Jump to general ISR
                ENDM


;*----------------------------------------------------------------------*
;*  PROCESSOR SPECIFIC DATA DEFINITIONS
;*----------------------------------------------------------------------*

IF (?RTX_CPU_TYPE = 1)
   ;***********
   ;* Type 1  *
   ;***********
      ;------------------------------------------------------------------
      ; Define the number and addresses of the interrupt enable registers
      ; 8051 -> 1 interrupt enable register
      ; (Set the not used registers to the same address as ?RTX_IE)

      INT_EN_MASK_NUMBER   EQU 1
      ?RTX_IE              DATA  0A8H
      ?RTX_IEN1            DATA  0A8H  ; not used
      ?RTX_IEN2            DATA  0A8H  ; not used

      ;------------------------------------------------------------------
      ; Generate the interrupt entry points supported by the peripherals
      ; of the selected CPU type.
      IF (?RTX_SYSTEM_TIMER = 0)
         ; Do NOT include the Timer 0 Vector  (INT-1)
         INT_ENTRY      0
         INT_ENTRY      2
         INT_ENTRY      3
         INT_ENTRY      4
      ELSEIF (?RTX_SYSTEM_TIMER = 1)
         ; Do NOT include the Timer 1 Vector  (INT-3)
         INT_ENTRY      0
         INT_ENTRY      1
         INT_ENTRY      2
         INT_ENTRY      4
      ENDIF

      ;------------------------------------------------------------------
      ; The following table attaches the interrupt numbers (0..31) to the
      ; corresponding bits in the interrupt enable masks of the specific
      ; processor.
      ; All three interrupt enable register contents must be defined
      ; for every interrupt number (even when the specific processor contains
      ; only one interrupt mask).
      ; Syntax: DB IE-content, IE1-content, IE2-content
      ;
      ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF  SEGMENT  CODE
                        RSEG  ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF

         ?RTX_INT_TO_BIT_TABLE_BASE:
                        DB 01H, 00H, 00H    ; INT_0  (P3.2/INT0)
                        DB 02H, 00H, 00H    ; INT_1  (Timer 0)
                        DB 04H, 00H, 00H    ; INT_2  (P3.3/INT1)
                        DB 08H, 00H, 00H    ; INT_3  (Timer 1)
                        DB 10H, 00H, 00H    ; INT_4  (Ser. channel)

      ;------------------------------------------------------------------
      ; Define the greatest supported interrupt number
      ?RTX_MAX_INT_NBR      EQU   4

PCON    DATA    87H

ENTER_IDLE       MACRO
;;
;;      Enter Idle Mode
;;      ---------------
;;      Not supported by all 8051 type processors (see manufacturer's
;;      data sheet !)
;;      To be used whenever entering idle state.
;;
            ORL     PCON, #01H          ; Set idle mode (leave by interrupt)
                                        ; (peripherals stay active)
         ENDM

ELSEIF (?RTX_CPU_TYPE = 2)
   ;**********
   ;* Type 2 *
   ;**********
      ;------------------------------------------------------------------
      ; Define the number and addresses of the interrupt enable registers
      ; 8052 -> 1 interrupt enable register
      ; (Set the not used registers to the same address as ?RTX_IE)

      INT_EN_MASK_NUMBER   EQU 1
      ?RTX_IE              DATA  0A8H
      ?RTX_IEN1            DATA  0A8H  ; not used
      ?RTX_IEN2            DATA  0A8H  ; not used

      ;------------------------------------------------------------------
      ; Generate the interrupt entry points supported by the peripherals
      ; of the selected CPU type.
      IF (?RTX_SYSTEM_TIMER = 0)
         ; Do NOT include the Timer 0 Vector  (INT-1)
         INT_ENTRY      0
         INT_ENTRY      2
         INT_ENTRY      3
         INT_ENTRY      4
         INT_ENTRY      5
      ELSEIF (?RTX_SYSTEM_TIMER = 1)
         ; Do NOT include the Timer 1 Vector  (INT-3)
         INT_ENTRY      0
         INT_ENTRY      1
         INT_ENTRY      2
         INT_ENTRY      4
         INT_ENTRY      5
      ELSEIF (?RTX_SYSTEM_TIMER = 2)
         ; Do NOT include the Timer 2 Vector (INT-5)
         INT_ENTRY      0
         INT_ENTRY      1
         INT_ENTRY      2
         INT_ENTRY      3
         INT_ENTRY      4
      ENDIF

      ;------------------------------------------------------------------
      ; The following table attaches the interrupt numbers (0..31) to the
      ; corresponding bits in the interrupt enable masks of the specific
      ; processor.
      ; All three interrupt enable register contents must be defined
      ; for every interrupt number (even when the specific processor contains
      ; only one interrupt mask).
      ; Syntax: DB IE-content, IE1-content, IE2-content
      ;
      ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF  SEGMENT  CODE
                        RSEG  ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF

         ?RTX_INT_TO_BIT_TABLE_BASE:
                        DB 01H, 00H, 00H    ; INT_0  (P3.2/INT0)
                        DB 02H, 00H, 00H    ; INT_1  (Timer 0)
                        DB 04H, 00H, 00H    ; INT_2  (P3.3/INT1)
                        DB 08H, 00H, 00H    ; INT_3  (Timer 1)
                        DB 10H, 00H, 00H    ; INT_4  (Ser. channel)
                        DB 20H, 00H, 00H    ; INT_5  (Timer 2)

      ;------------------------------------------------------------------
      ; Define the greatest supported interrupt number
      ?RTX_MAX_INT_NBR      EQU   5

PCON    DATA    87H

ENTER_IDLE       MACRO
;;
;;      Enter Idle Mode
;;      ---------------
;;      Not supported by all 8052 type processors (see manufacturer's
;;      data sheet !)
;;      To be used whenever entering idle state.
;;
            ORL     PCON, #01H          ; Set idle mode (leave by interrupt)
                                        ; (peripherals stay active)
         ENDM





;;;;;;;;;;;;;;;;;;;ADDED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ELSEIF (?RTX_CPU_TYPE = 150) OR (?RTX_CPU_TYPE = 80)
   ;**************
   ;* Type 150&80*	'15'&'8'represent the STC15&8 series '0' for distinguish 
   ;**************
      ;------------------------------------------------------------------
      ; Define the number and addresses of the interrupt enable registers
      ; stc15 -> 3 interrupt enable register
      ; (Set the not used registers to the same address as ?RTX_IE)

      INT_EN_MASK_NUMBER   EQU 3
      ?RTX_IE              DATA  0A8H  ;IE  
      ?RTX_IEN1            DATA  08FH  ;INT_CLKO
      ?RTX_IEN2            DATA  0AFH  ;IE2 

      ;------------------------------------------------------------------
      ; Generate the interrupt entry points supported by the peripherals
      ; of the selected CPU type.
      IF (?RTX_SYSTEM_TIMER = 0)
         ; Do NOT include the Timer 0 Vector  (INT-1)
         INT_ENTRY      0
		 ; Do NOT include the Timer 0 Vector  (INT-1)
         INT_ENTRY      2
         INT_ENTRY      3
         INT_ENTRY      4
		 INT_ENTRY      5
       
 
         INT_ENTRY      8
         INT_ENTRY      9
         INT_ENTRY      10
         INT_ENTRY      11
         INT_ENTRY      12

         INT_ENTRY      16
		 INT_ENTRY      17
		 INT_ENTRY      18
		 INT_ENTRY      19
		 INT_ENTRY      20

      ELSEIF (?RTX_SYSTEM_TIMER = 1)
         ; Do NOT include the Timer 1 Vector  (INT-3)
         INT_ENTRY      0
         INT_ENTRY      1
         INT_ENTRY      2
         ; Do NOT include the Timer 1 Vector  (INT-3)
         INT_ENTRY      4
		 INT_ENTRY      5
       
         INT_ENTRY      8
         INT_ENTRY      9
         INT_ENTRY      10
         INT_ENTRY      11
         INT_ENTRY      12

         INT_ENTRY      16
		 INT_ENTRY      17
		 INT_ENTRY      18
		 INT_ENTRY      19
		 INT_ENTRY      20

      ENDIF

      ;------------------------------------------------------------------
      ; The following table attaches the interrupt numbers (0..31) to the
      ; corresponding bits in the interrupt enable masks of the specific
      ; processor.
      ; All three interrupt enable register contents must be defined
      ; for every interrupt number (even when the specific processor contains
      ; only one interrupt mask).
      ; Syntax: DB IE-content, IE1-content, IE2-content
      ;
      ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF  SEGMENT  CODE
                        RSEG  ?RTX?RTX_INT_TO_BIT_TABLE?RTXCONF

         ?RTX_INT_TO_BIT_TABLE_BASE:
                DB 01H, 00H, 00H    ; INT_0   (P3.2/INT0)
                DB 02H, 00H, 00H    ; INT_1   (Timer 0)
                DB 04H, 00H, 00H    ; INT_2   (P3.3/INT1)
                DB 08H, 00H, 00H    ; INT_3   (Timer 1)
                DB 10H, 00H, 00H    ; INT_4   (Ser. channel 1)
                DB 20H, 00H, 00H    ; INT_5   (A/D-Converter)
										                        DB 00H, 00H, 00H    ; INT_6   not used(LVD)
										                        DB 00H, 00H, 00H    ; INT_7   (CCP/PCA)		  can¡®t support

                DB 00H, 00H, 01H    ; INT_8   (Ser. channel 2)
                DB 00H, 00H, 02H    ; INT_9   (SPI)
                DB 00H, 01H, 00H    ; INT_10  (P3.6/__INT2)
                DB 00H, 02H, 00H    ; INT_11  (P3.7/__INT3)
                DB 00H, 00H, 04H    ; INT_12  (Timer 2)
																DB 00H, 00H, 00H    ; INT_13                  reserve
										                        DB 00H, 00H, 00H    ; INT_14                  reserve
										                        DB 00H, 00H, 00H    ; INT_15                  reserve

                DB 00H, 04H, 00H    ; INT_16  (P3.0/__INT4)
                DB 00H, 00H, 08H    ; INT_17  (Ser. channel 3)
                DB 00H, 00H, 10H    ; INT_18  (Ser. channel 4)
                DB 00H, 00H, 20H    ; INT_19  (Timer 3)
                DB 00H, 00H, 40H    ; INT_20  (Timer 4)
																DB 00H, 00H, 00H    ; INT_21  (Comparator)	  can¡®t support
																DB 00H, 00H, 00H    ; INT_22  (PWM)			  can¡®t support
																DB 00H, 00H, 00H    ; INT_23  (PWM FD)        can¡®t support
																DB 00H, 00H, 00H    ; dummy

      ;------------------------------------------------------------------
      ; Define the greatest supported interrupt number
      ?RTX_MAX_INT_NBR      EQU   24

PCON    DATA    87H

ENTER_IDLE       MACRO
;;
;;      Enter Idle Mode
;;      ---------------
;;      Not supported by all 8051 type processors (see manufacturer's
;;      data sheet !)
;;      To be used whenever entering idle state.
;;
            ORL     PCON, #01H          ; Set idle mode (leave by interrupt)
            NOP                          ; (peripherals stay active)
			NOP
			NOP
			NOP
         ENDM
		 
;;;;;;;;;;;;;;;;;;;ADDED;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







$ELSE

   THIS ?RTX_CPU_TYPE VALUE IS NOT SUPPORTED BY THIS MODULE !!

$ENDIF



$EJECT
;*----------------------------------------------------------------------*
;*  DEFINITIONS COMMON FOR ALL PROCESSORS
;*----------------------------------------------------------------------*

      ;------------------------------------------------------------------
      ; Define the internal interrupt mask variables. The variables are
      ; used for the Interrupt-Handling.
      ; Initialise the enable bits for the Interrupt-Enable-Masks
      ;
      IF (INT_EN_MASK_NUMBER = 1)
         ?RTX?INT_MASK?RTXCONF  SEGMENT  DATA
                                RSEG  ?RTX?INT_MASK?RTXCONF
            ; variables for first mask
            ?RTX_NM_IE:     DS 1
            ?RTX_D_IE:      DS 1
            ?RTX_ND_IE:     DS 1
            ; variables for second mask (not used)
            ?RTX_NM_IE1:    DS 0
            ?RTX_D_IE1:     DS 0
            ?RTX_ND_IE1:    DS 0
            ; variables for third mask (not used)
            ?RTX_NM_IE2:    DS 0
            ?RTX_D_IE2:     DS 0
            ?RTX_ND_IE2:    DS 0

            ; RTX-51 calls this routine in the initialisation phase
            ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF  SEGMENT  CODE
                                    RSEG  ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF
               ?RTX_INIT_INT_REG_FLAGS:
                                    CLR   ?RTX_ENA_INT_REG1
                                    CLR   ?RTX_ENA_INT_REG2
                                    RET
      ELSEIF (INT_EN_MASK_NUMBER = 2)
         ?RTX?INT_MASK?RTXCONF  SEGMENT  DATA
                                RSEG  ?RTX?INT_MASK?RTXCONF
            ; variables for first mask
            ?RTX_NM_IE:     DS 1
            ?RTX_D_IE:      DS 1
            ?RTX_ND_IE:     DS 1
            ; variables for second mask
            ?RTX_NM_IE1:    DS 1
            ?RTX_D_IE1:     DS 1
            ?RTX_ND_IE1:    DS 1
            ; variables for third mask (not used)
            ?RTX_NM_IE2:    DS 0
            ?RTX_D_IE2:     DS 0
            ?RTX_ND_IE2:    DS 0

            ; RTX-51 calls this routine in the initialisation phase
            ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF  SEGMENT  CODE
                                    RSEG  ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF
               ?RTX_INIT_INT_REG_FLAGS:
                                    SETB  ?RTX_ENA_INT_REG1
                                    CLR   ?RTX_ENA_INT_REG2
                                    RET
      ELSEIF (INT_EN_MASK_NUMBER = 3)
         ?RTX?INT_MASK?RTXCONF  SEGMENT  DATA
                                RSEG  ?RTX?INT_MASK?RTXCONF
            ; variables for first mask
            ?RTX_NM_IE:     DS 1
            ?RTX_D_IE:      DS 1
            ?RTX_ND_IE:     DS 1
            ; variables for second mask
            ?RTX_NM_IE1:    DS 1
            ?RTX_D_IE1:     DS 1
            ?RTX_ND_IE1:    DS 1
            ; variables for third mask
            ?RTX_NM_IE2:    DS 1
            ?RTX_D_IE2:     DS 1
            ?RTX_ND_IE2:    DS 1

            ; RTX-51 calls this routine in the initialisation phase
            ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF  SEGMENT  CODE
                                    RSEG  ?RTX?RTX_INIT_INT_REG_FLAGS?RTXCONF
               ?RTX_INIT_INT_REG_FLAGS:
                                    SETB  ?RTX_ENA_INT_REG1
                                    SETB  ?RTX_ENA_INT_REG2
                                    RET
      ENDIF


      ;------------------------------------------------------------------
      ; Define the System-Timer specific values
      ; This values are normally for all 8051 family-members identical.
      ;
      IF (?RTX_SYSTEM_TIMER = 0)
         ?RTX_TLOW          DATA  8AH
         ?RTX_THIGH         DATA  8CH
         ?RTX_TCON          DATA  88H
         ?RTX_TMOD          DATA  89H
         ?RTX_TFLAG         BIT   8DH
         ?RTX_TCONTROL      BIT   8CH
         ; TCON init-masks
         ; The clock will be initialized with: ANL TCON, #RTX_TCON_AND_MASK
         ;                                     ORL TCON, #RTX_TCON_OR_MASK
         ; --> not used for this timer
         ?RTX_TCON_AND_MASK EQU   0FFH
         ?RTX_TCON_OR_MASK  EQU   000H
         ; TMOD init-masks
         ; The clock will be initialized with: ANL TMOD, #RTX_TMOD_AND_MASK
         ;                                     ORL TMOD, #RTX_TMOD_OR_MASK
         ?RTX_TMOD_AND_MASK EQU   0F0H
         ?RTX_TMOD_OR_MASK  EQU   01H
         ; System-Clock interrupt number
         ?RTX_CLK_INT_NBR   EQU   1
      ELSEIF (?RTX_SYSTEM_TIMER = 1)
		 ?RTX_TLOW          DATA  8BH
		 ?RTX_THIGH         DATA  8DH
		 ?RTX_TCON          DATA  88H
		 ?RTX_TMOD          DATA  89H
		 ?RTX_TFLAG         BIT   8FH
		 ?RTX_TCONTROL      BIT   8EH
		 ; TCON init-masks
		 ; The clock will be initialized with: ANL TCON, #RTX_TCON_AND_MASK
		 ;                                     ORL TCON, #RTX_TCON_OR_MASK
		 ; --> not used for this timer
		 ?RTX_TCON_AND_MASK EQU   0FFH
		 ?RTX_TCON_OR_MASK  EQU   000H
		 ; TMOD init-masks
		 ; The clock will be initialized with: ANL TMOD, #RTX_TMOD_AND_MASK
		 ;                                     ORL TMOD, #RTX_TMOD_OR_MASK
		 ?RTX_TMOD_AND_MASK EQU   0FH
		 ?RTX_TMOD_OR_MASK  EQU   10H
		 ; Interrupt Vector Entry
		 ?RTX_CLK_INT_NBR   EQU   3
      ELSEIF (?RTX_SYSTEM_TIMER = 2)
         ?CPU   EQU     ?RTX_CPU_TYPE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;modify;;;;;;;;;;;;;;;;
		 IF ( ?CPU=150 ) OR ( ?CPU=80 )     
         ;
         ; These value s apply to  of the STC 15 series only.
         ;
			  
		 STC15 CAN'T SUPPORT T2 Because of 'AUXR' can't	be bit. 
		 So ?RTX_SYSTEM_TIMER CAN'T EQU 2!
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;modify;;;;;;;;;;;;;;;;
        ELSEIF(?CPU=2)
         ;
         ; These values apply to timer 2 of the 8052, 8xC51Fx, 80C51GB and
         ; 80C320/33/530, C501/501/503 only.
         ;
         ?RTX_TLOW          DATA  0CCH  ; TL2
         ?RTX_THIGH         DATA  0CDH  ; TH2
         ?RTX_TCON          DATA  0C8H  ; T2CON
         ?RTX_TMOD          DATA  0C9H  ; T2MOD
         ?RTX_TFLAG         BIT   0CFH  ; TF2 (T2CON.7)
         ?RTX_TCONTROL      BIT   0CAH  ; TR2 (T2CON.2)
         ; TCON init-masks
         ; The clock will be initialized with: ANL TCON, #RTX_TCON_AND_MASK
         ;                                     ORL TCON, #RTX_TCON_OR_MASK
         ?RTX_TCON_AND_MASK EQU   000H  ; T2CON = 000H
         ?RTX_TCON_OR_MASK  EQU   000H
         ; TMOD init-masks
         ; The clock will be initialized with: ANL TMOD, #RTX_TMOD_AND_MASK
         ;                                     ORL TMOD, #RTX_TMOD_OR_MASK
         ?RTX_TMOD_AND_MASK EQU   000H  ; T2MOD = 000H
         ?RTX_TMOD_OR_MASK  EQU   000H
         ; Interrupt Vector Entry
         ?RTX_CLK_INT_NBR   EQU   5
        ENDIF 
      ENDIF

      ;------------------------------------------------------------------
      ; System-Timer Interrupt Vector Entry
      ;
      CSEG AT(?RTX_INTBASE+3+(8*?RTX_CLK_INT_NBR))
      IF (?RTX_SYSTEM_TIMER = 2)
         CLR   ?RTX_TFLAG
      ENDIF
         LJMP  ?RTX_SYSCLK_INTHNDLR

      ;------------------------------------------------------------------
      ; Definitions for Code-Bank-Switching support
      ;
      IF (?RTX_BANKSWITCHING = 0)
         ; Dummy definitions when no Bank-Switching is used
         ; (just to satisfy the Linker)
         ;
         ?B_CURRENTBANK       EQU  0H
         ?RTX_SWITCHBANK      EQU  0H
         ?RTX_SAVE_INT_BANK   EQU  0H
      ELSEIF (?RTX_BANKSWITCHING = 1)
         ; ----------------------------------------------------------------
         ;                   !!! IMPORTANT NOTICE !!!
         ; Set ?B_RTX (defined in L51_BANK.A51 V1.4b up) to one !
         ; ----------------------------------------------------------------
         ; RTX-51 reads the actual banknumber from the external symbol
         ; ?B_CURRENTBANK whenever it suspends a task (task-switch).
         ; With this value in the Accu RTX-51 calls ?RTX_SWITCHBANK when
         ; the task is reactivated.
         ;
         ; The routine ?RTX_SWITCHBANK may use the following:
         ;     - the registers A, B, DPTR, PSW and the Stack
         ;     - the registers R0, R1, R2, R3 and R7 of the actual
         ;       registerbank (but NOT the registers R4,R5,R6!!)
         ;
         ; Do NOT change the actual registerbank !
         ;
         ; RTX-51 calls this routine with all Interrupts disabled.
         ;
         ; INPUT: ACC -> Banknumber to switch
         ;               (same definition as in ?B_CURRENTBANK)
         ;
         ?RTX?RTX_SWITCHBANK?RTXCONF  SEGMENT  CODE
                              RSEG  ?RTX?RTX_SWITCHBANK?RTXCONF

            B  DATA  0F0H        ; Define the B-Register

            ?RTX_SWITCHBANK:
                         ; Check if bankswitching required
                         CJNE A, ?B_CURRENTBANK, SWITCH
                         RET
                         ; Extract the Banknumber
SWITCH:                  ANL  A, #?B_MASK
                         MOV  B, #?B_FACTOR
                         DIV  AB
                         MOV  R7, A
                         JMP  _SWITCHBANK    ; Switchbank-Routine in L51_BANK

         ; Byte variable for the actual banknumber in the context of the
         ; suspended task
         ?RTX?RTX_SUSP_BANK?RTXCONF SEGMENT DATA
                              RSEG ?RTX?RTX_SUSP_BANK?RTXCONF
            ?RTX_SAVE_INT_BANK:   DS 1
      ENDIF

      
      ;------------------------------------------------------------------
      ; Context-space in each Fast-Task stack in internal RAM
      ;
      IF (?RTX_BANKSWITCHING = 0)
         ?RTX_INTREGSIZE  EQU   3       ; SP/reentrant SP (P2:?C_PBP)
      ELSEIF (?RTX_BANKSWITCHING = 1)
         ?RTX_INTREGSIZE  EQU   4       ; SP/reentrant SP (P2:?C_PBP)/Bank
      ENDIF

      ;------------------------------------------------------------------
      ; 
      ; RTX Idle Function
      ;
      ; RTX-51 jumps to this code when entering the idle loop
      
        ?RTX?RTX_IDLE_FUNC?RTXCONF SEGMENT  CODE
                                    RSEG  ?RTX?RTX_IDLE_FUNC?RTXCONF
        ?RTX_IDLE_FUNC:
IF (?RTX_USE_IDLE = 1)
                ; Switch to idle mode when configured
                ENTER_IDLE
ENDIF                                    
                JMP   ?RTX_IDLE_FUNC

      ;------------------------------------------------------------------
      ; Define the Fast-Task stack and context space
      ;
      ?RTX?FTASKDATA?U     SEGMENT  IDATA
                           RSEG     ?RTX?FTASKDATA?U
                           DS ?RTX_INTSTKSIZE


      ;------------------------------------------------------------------
      ; Define the mailbox FIFOs
      ; ========================
      ; NOTE: this segment must be page-aligned; do not change !

        ?RTX?RTX_MBX_PAGE  SEGMENT XDATA PAGE
                           RSEG    ?RTX?RTX_MBX_PAGE

IF (?RTX_MAILBOX_SUPPORT = 1)
?RTX_MBX_PAGE:       DS      8*32
ELSE
?RTX_MBX_PAGE:       DS      1  ; Use 1 instead of 0 to avoid L51 error
ENDIF
?RTX_MBX_PAGE_END:   DS      0


      ;------------------------------------------------------------------
      ; Define the semaphore FIFOs
      ; ==========================
      ; NOTE: this segment must be page-aligned; do not change !

        ?RTX?RTX_SEM_PAGE  SEGMENT XDATA PAGE
                     RSEG  ?RTX?RTX_SEM_PAGE

IF (?RTX_SEMAPHORE_SUPPORT = 1)
?RTX_SEM_PAGE:       DS      8*16
ELSE
?RTX_SEM_PAGE:       DS      1  ; Use 1 instead of 0 to avoid L51 error
ENDIF
?RTX_SEM_PAGE_END:   DS      0


;*----------------------------------------------------------------------*
;*  END OF MODULE
;*----------------------------------------------------------------------*
END
