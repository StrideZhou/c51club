;************************************************************************
;*                                                                      *
;*      R T X - 5 1     S E T U P                                       *
;*                                                                      *
;*----------------------------------------------------------------------*
;*                                                                      *
;*      Filename:       RTXSETUP.DCL                                    *
;*      Date:            9-MAY-1996                                     *
;*      Language:       Keil C (C51)                                    *
;*      Dev.system:     IBM PC (MS-WIN 95)                              *
;*      Targetsystem:   Any system based upon 8051 up                   *
;*                                                                      *
;*      Purpose:        Gives the user the possibility to configure RTX *
;*                      to meet his application specific requirements.  *
;*                                                                      *
;*                                  *** NOTE ***                        *
;*                                                                      *
;*                      - Read user manual carefully before changing    *
;*                        this file.                                    *
;*                      - This module may be used without any changes   *
;*                        for most applications !                       *
;*                      - This is an include file for RTXCONF.A51       *
;*                      - If any changes are done then RTXCONF.A51 has  *
;*                        to be rebuilt:                                *
;*                                              A51 RTXCONF.A51         *
;*                                                                      *
;*----------------------------------------------------------------------*
;* Rev. | Released | Programmer  | Comments                             *
;*----------------------------------------------------------------------*
;* 5.10 | 09.05.96 | EG          | Release V 5.10                       *
;************************************************************************
;*  (c)  METTLER  &  FUCHS  AG,  CH-8953 Dietikon,  Tel. 01-740 41 00   *
;************************************************************************

;*----------------------------------------------------------------------*
;*                                                                      *
;*                         O V E R V I E W                              *
;*                                                                      *
;*      Configuration Options:                                          *
;*                                                                      *
;*              1. CPU TYPE                                             *
;*              2. SYSTEM CLOCK                                         *
;*              3. INITIAL INTERRUPT-ENABLE REGISTER VALUES             *
;*              4. FAST TASK STACK- AND ENVIRONMENT SIZE                *
;*              5. STANDARD TASK CONTEXT STACK SIZE                     *
;*              6. REENTRANT STACK SIZE                                 *
;*              7. ROUND ROBIN FLAG                                     *
;*              8. BANK SWITCHING FLAG                                  *
;*              9. INTERRUPT TABLE BASE ADDRESS                         *
;*             10. MAILBOX-SUPPORT FLAG                                 *
;*             11. SEMAPHORE-SUPPORT FLAG                               *
;*             12: IDLE MODE                                            *
;*                                                                      *
;*      The configuration may be done directly by editing the include   *
;*      file RTXSETUP.DCL or (more easily) by using the interactive     *
;*      configuration program.                                          *
;*                                                                      *
;*----------------------------------------------------------------------*


;  1. CPU TYPE
;  ===========
;
;    CPU_TYPE stands for the desired microprocessor type and can be 
;    selected from the following table:
;
;  ====================================================================
;  | Manufacturer / Model                                   | 'xx'    |
;  ====================================================================
;  | Intel/Siemens/Philips/AMD/MHS/OKI                      |   1     |
;  |      8051, 8031, 8751, 80C51, 80C31, 87C51             |         |
;  --------------------------------------------------------------------
;  | Intel/Siemens/AMD 80C52, 80C32                         |   2     |
;  --------------------------------------------------------------------
;  | STC     15series                                       |  150    |
;  ====================================================================
;
?RTX_CPU_TYPE   EQU             150



;  2. SYSTEM CLOCK
;  ===============
;
;  (Baiscally Timer 0, Timer 1 and Timer 2 are supported)
;  Set ?RTX_SYSTEM_TIMER to 0 for Timer 0
;  Set ?RTX_SYSTEM_TIMER to 1 for Timer 1
;  Set ?RTX_SYSTEM_TIMER to 2 for Timer 2 
;  NOTE: Timer 2 is not supported for all CPU types(include STC15).  If it 
;  is specified for a not supported CPU type, then an error message will be
;        generated when assembling RTXCONF.A51.
;  (Default-value: Timer 0)
;
?RTX_SYSTEM_TIMER    EQU 0



;  3. INITIAL INTERRUPT-ENABLE REGISTER VALUES
;  ===========================================
;
;  Some 8051 family members have specific bits in their Interrupt-Enable
;  Registers, which have other functions than interrupt enable/disable.
;  Here you can set the initial values of these special bits.
;  (Normally RTX-51 will set all not used bits in the interrupt enable mask
;  to 0).
;  You MUST NOT set bits dedicated to interrupt enable/disable !
;  NOTE: ?RTX_IEN1_INIT is only used for processors with at least 2 interrupt 
;        masks.
;        ?RTX_IEN2_INIT is only used for processors with 3 interrupt masks.
;
?RTX_IE_INIT      EQU   0
?RTX_IEN1_INIT    EQU   0
?RTX_IEN2_INIT    EQU   0


;  4. FAST TASK STACK- AND ENVIRONMENT SIZE
;  ========================================
;
;  This constant defines the stack- and environment size reserved per
;  defined fast task.  These areas are located in IDATA space.
;
;  Minimum values (per task):
;  - 3 Bytes for internal use
;  - 2 Bytes for the task code start address
;  Do not set to less than 9 bytes
;  Add 3 Bytes when code bank switching is used (?RTX_BANKSWITCHING = 1) !
;  (Default value: 12 Bytes)
;
?RTX_INTSTKSIZE      EQU   24


;  5. STANDARD TASK CONTEXT STACK SIZE
;  ===================================
; 
;  This constant defines the maximum size of stack data stored in the 
;  context area of a standard task.  For each defined standard task such an
;  area is reserved in XDATA space.
;  
;  (Default value: 32 Bytes)
;
?RTX_EXTSTKSIZE      EQU   32


;  6. REENTRANT STACK SIZE
;  =======================
;
;  This constnat defines the maximum size of the reentrant stack.  For each
;  defined task such an area is reserved in XDATA space.
;
;  The greatest possible reentrant-stack size is 256-18-?RTX_EXTSTKSIZE !!
;  (Default value: 50 Bytes)
;
?RTX_EXTRENTSIZE     EQU   50


;  7. ROUND ROBIN FLAG
;  ===================
;
;  0 --> Do not use round robin scheduling
;  1 --> Use round robin scheduling
;  (Default value: 0)
;
?RTX_TIMESHARING     EQU   1


;  8. BANK SWITCHING FLAG
;  ======================
;
;  For code bank switching details see BL51 documentation and READ.ME file
;  0 --> code bank switching is disabled
;  1 --> code bank switching is enabled
;  (Default value: 0)
;
;  !!! IMPORTANT NOTICE !!!
;  Set ?B_RTX contained in L51_BANK.A51 (V1.4b up) to one, when using
;  code bank switching together with RTX-51
;
?RTX_BANKSWITCHING   EQU   0


;  9. INTERRUPT TABLE BASE ADDRESS
;  ===============================
;
;  Normally the interrupt table is located at address 0000H.  For special
;  hardware configurations, like flash eprom systems, there may be a need
;  to reroute interrupts to a table at a different address.  If an address
;  different than 0000H is used, then the user has to supply code to re-
;  route each used interrupt vector to an address with the offset declared
;  below.
;  For standard systems this address has to be 0000H.
;
?RTX_INTBASE    EQU     0


;  10. MAILBOX-SUPPORT FLAG
;  ========================
;
;  This flag determines if memory is allocated for the mailbox FIFOs or not.
;  If set to 0, then no wait for a mailbox is possible.  Associated calls
;  will return a NOT_OK in this case.
;  Set ?RTX_MAILBOX_SUPPORT to 0 if mailbox services are not desired.
;  Set ?RTX_MAILBOX_SUPPORT to 1 if mailbox services are desired.
;  (Default is 1)
;
?RTX_MAILBOX_SUPPORT    EQU     1


;  11. SEMAPHORE-SUPPORT FLAG
;  ==========================
;
;  This flag determines if memory is allocated for the semaphore FIFOs or not.
;  If set to 0, then no wait for a semaphore is possible.  Associated calls
;  will return a NOT_OK in this case.
;  Set ?RTX_SEMAPHORE_SUPPORT to 0 if semaphore services are not desired.
;  Set ?RTX_SEMAPHORE_SUPPORT to 1 if semaphore services are desired.
;  (Default is 1)
;  NOTE: if an increased XDATA usage compared with RTX-51 V 4.x has to be
;         avoided, then this flag should be set to 0 !
;
?RTX_SEMAPHORE_SUPPORT    EQU     1


;  12. IDLE MODE
;  =============
;
;  If this option is enabled, then each time the RTX idle loop is 
;  entered the cpu is switched to idle mode. This feature is supported 
;  for selected cpu's only.  enabling it for other cpu's will have no effect.                           
;
;  USE_IDLE        = 0: do not use the idle mode        
;                  = 1: set cpu to idle mode during system idle time

?RTX_USE_IDLE             EQU     1


;*----------------------------------------------------------------------*
;*              END of INCLUDE FILE RTXSETUP.DCL                        *

