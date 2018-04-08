list 	p=16f1508 		; Define processor 
	
#include	p16f1508.inc    	; Standard variable definitions

;               +---u---+
;          Vdd <|1    20|> Vss
;          RA5 <|2    19|> RA0/ICSPDAT
;          RA4 <|3    18|> RA1/ICSPCLK
; MCLR/Vpp/RA3 <|4    17|> RA2
;    CWG1A/RC5 <|5    16|> RC0
;    CWG1B/RC4 <|6    15|> RC1
;          RC3 <|7    14|> RC2
;          RC6 <|8    13|> RB4
;          RC7 <|9    12|> RB5
;          RB7 <|10   11|> RB6
;               +-------+

; --------------------------------------
; Configuration Bits & Error Level
; --------------------------------------
 __CONFIG _CONFIG1, _FOSC_INTOSC & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _BOREN_OFF & _CLKOUTEN_OFF
 __CONFIG _CONFIG2, _WRT_OFF & _STVREN_OFF & _LVP_OFF

 errorlevel -302			; Suppress assembler Messages pertaining to banks, so be careful!
 
; --------------------------------------
; Core Registers (present in all Banks)
; --------------------------------------
; INDF0 & INDF1
; PCL
; STATUS
; FSR0L & FSR0H & FSR1L & FSR1H
; BSR
; WREG
; PCLATH
; INTCON 
; --------------------------------------

	ORG		0x000		; Reset vector.
	goto		Main		; Go to main program.
	ORG		0x004		; Interrupt vector location 
                 			; NOTE: W, STATUS, BSR, FSTs & PCLATH are saved 
					; automatically in Shadow regs (Bank 31)
	retfie				; Return from interrupt.
	
Main
; ---------[ Interrupts ]-------------------------------------------
	movlw	b'01000000'		; Interrupts disabled, PEIE bit6 enabled
	clrf	INTCON			; INTCON is a Core Register (in all banks)
	banksel	PIE2			; [Bank 1]
	movlw	b'00000100'		; NCO1IE = 1 (enabled) for NCO Interrupts
	movwf	PIE2
	banksel	PIR2			; [Bank 0]
	clrf	PIR2			; Peripheral Inter. Flags (NCO1IF bit2 = 1 on Accum.Overflow)
; ---------[ Oscillator Setup ]--------------------------------------
	banksel	OSCCON			; [Bank 1]
	movlw	b'01111000'		; Internal OSC = 16 MHz
	movwf	OSCCON
	btfss	OSCSTAT, HFIOFR		; Internal OSC running?
	goto	$-1             	; No, loop until running.
	btfss	OSCSTAT, HFIOFS		; OSC stable?
	goto	$-1 			; No, loop until stable.
; ---------[ Ports & I/O Setup ]------------------------------------
	banksel	PORTA			; [Bank 0] Initialize Ports.
	clrf	PORTA
	clrf	PORTB
	clrf	PORTC
	banksel	LATA			; [Bank 2] Clear data Latches.
	clrf	LATA
	clrf	LATB
	clrf	LATC
	banksel	ANSELA			; [Bank 3] Setup I/O.
	clrf	ANSELA			; PORTA = Digital I/O.
	clrf 	ANSELB			; PORTB = Digital I/O. (NOTE: missing on 16F1503)
	clrf 	ANSELC			; PORTC = Digital I/O.
	banksel	OPTION_REG		; [Bank 1]
	movlw	b'11000010'		; Pull-ups Off, TMR0 Prescaler = 1:8
	movwf	OPTION_REG
	movlw	b'11111111'		; Make CWG1A & CWG1B Inputs for now. (See CWG Setup below.)
	movwf 	TRISC			;  PORTC 
	movlw	b'00000000'		; All outputs
	movwf	TRISB			;  PORTB 
	movlw	b'11101111'		; RA4 the only Output (pin 3)
	movwf	TRISA			;  PORTA 
; ---------[ CWG Setup ]------------------------------------------
; The sequence below follows "26.11 Configuring the CWG" in the PIC16(L)F1508/9 datasheet:
; http://ww1.microchip.com/downloads/en/DeviceDoc/40001609E.pdf
; CWG1A (RC1) & CWG1B (RC0) are configured as Inputs for now.
	banksel	CWG1CON0		; [Bank 13]
	bcf	CWG1CON0, 7		; Clear GxEN (bit 7) to Disable CWG.
	movlw	.20			; Put 20d into "CWG Rising DEAD-BAND Count Register"
	movwf	CWG1DBR			;  (20 clock cycles = 1.25us @ HFINTOSC=16MHz)
	movlw	.20			; Put 20d into "CWG Falling DEAD-BAND Count Register"
	movwf	CWG1DBF
	movlw	b'10000000'		; GxASE(b7)=1, GxARSEN(b6)=0
	movwf	CWG1CON2		;  (CWG in Shutdown State, Auto-Restart Disabled)
	movlw	b'10100110'		; CWG1A & CWG1B outputs LO on Shutdown, Source = NCO1
	movwf	CWG1CON1
	movlw	b'01100001'		; Leave GxEN=0, CWG1A/B to Output pins, Normal Polarity, HFINTOSC
	movwf	CWG1CON0
	bsf	CWG1CON0, 7		; Set GxEN (bit 7) to Enable CWG.
	banksel	TRISC			; [Bank 1]
	movlw	b'11111100'		; RC0=CWG1B, RC1=CWG1B (set to Outputs)
	movwf 	TRISC			;  PORT C
	banksel	CWG1CON2		; [Bank 13]
	bcf	CWG1CON2, 7		; Clear GxASE to start the CWG.
; ---------[ NCO Setup ]------------------------------------------
	banksel	APFCON			; [Bank 2]
	clrf 	APFCON			; NCO1 function is on RC1 (NCO not using pin. See NC01CON below.)
	banksel NCO1CLK			; [Bank 9]
	clrf	NCO1CLK			; NxPWS n/a due to fixed DC, clock source HFINTOSC (16 MHz).
	clrf	NCO1ACCU		; Clear the Accumulator (UPPER->HI->LO).
	clrf	NCO1ACCH
	clrf	NCO1ACCL
	clrf	NCO1INCH		; HI Incr.Value = 0  (NCO1INCH must execute before NCOINCL)
	movlw	.66			; LO Incr.Value = 66d
	movwf	NCO1INCL		;  Foverflow = (NCO Clock x Incr.Value)/(2^21)=504Hz square-wave
	movlw	b'10010000'		; Enable NCO, Disable Out-pin, Polarity=LO(inverted), Fixed D.C.
	movwf	NCO1CON			;  Bit5 (NxOUT) is 1 when NCO output is HI, 0 when LO.
; ------------------------------------------------------------------
Loop	
	goto	Loop			; Do nothing else.
	end 
