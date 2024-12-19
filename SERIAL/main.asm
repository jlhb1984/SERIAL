;
; SERIAL.asm
;
; Created: 10/12/2024 4:23:42 p. m.
; Author : Jose Luis Hurtado
; Se incluye las 2 configuraciones, master con PB0=1 y slave con PB=0.
; ASIGNACIÓN DE PINES:
;	PORTB,0: MASTER/SLAVE.
;	PORTB,1: SPI_STC CREATED.
;	PORTB,2: SPDR READ.
;	PORTB,3: LIBRE AIN1. SLAVE SELECTED=1, MASTER SELECTED=0.
;	PORTB,4: SS'.
;	PORTB,5: MISO.
;	PORTB,6: MOSI.
;	PORTB,7: SCK.
;	PORTD	SALIDA PARA VER SPDR.

; Replace with your application code

.INCLUDE	"M16ADEF.INC"
.CSEG
.ORG		0
JMP			START

.ORG		$014
JMP		SPI_STC
		
SPI_STC:
	SBI		PORTB,1
	SBIS	SPSR,7
	RJMP	SPI_STC
	IN		R16,SPDR
	OUT		PORTD,R16
	SBI		PORTB,2
	LDI		R16,0B01000000	;ENVÍO @.
	OUT		SPDR,R16	
	SBIS	PINB,0
	JMP		SLAVE_C

MASTER_C:
	LDI		R16,0B10101110	;OUT-IN-OUT-IN-OUT-OUT-OUT-IN MASTER CONFIGURATION.	
	OUT		DDRB,R16	
	LDI		R16,0B00000000
	OUT		SPSR,R16		;SPIE=F	SP=F _ _ _ SPI2X=0 _ _	
	LDI		R16,0B01010000	;SPIE=1 SPE=1 DORD=0 MSTR=1 CPOL=0 CPHA=0 SPR1SPR0=00 (FOSC/4)
	OUT		SPCR,R16
	JMP		EXIT

SLAVE_C:
	LDI		R16,0B01001110	;IN-OUT-IN-IN-OUT-OUT-OUT-IN SLAVE CONFIGURATION.	
	OUT		DDRB,R16
	LDI		R16,0B00000000
	OUT		SPSR,R16		;SPIE=F	SP=F _ _ _ SPI2X=0 _ _	
	LDI		R16,0B11000000	;SPIE=1 SPE=1 DORD=0 MSTR=0 CPOL=0 CPHA=0 SPR1SPR0=00 (FOSC/4)
	OUT		SPCR,R16

EXIT:		
	SEI
	RETI	

START:
	LDI		R16,HIGH(RAMEND)
	OUT		SPH,R16
	LDI		R16,LOW(RAMEND)
	OUT		SPL,R16
	LDI		R16,0B11111111
	OUT		DDRD,R16

MS:
	SBIS	PINB,0
	RJMP	SLAVE
	RJMP	MASTER

MASTER:
	LDI		R16,0B10101110	;OUT-IN-OUT-IN-OUT-OUT-OUT-IN MASTER CONFIGURATION.	
	OUT		DDRB,R16	
	LDI		R16,0B00000000
	OUT		SPSR,R16		;SPIE=F	SP=F _ _ _ SPI2X=0 _ _
	LDI		R16,0B11010000	;SPIE=0 SPE=1 DORD=0 MSTR=1 CPOL=0 CPHA=0 SPR1SPR0=00 (FOSC/4)
	OUT		SPCR,R16
	LDI		R16,0B01000000	;ENVIO @
	OUT		SPDR,R16
	OUT		PORTD,R16
	SEI

TX:
	SBIS	SPSR,7
	RJMP	TX
	RJMP	END

SLAVE:
	LDI		R16,0B01001110	;IN-OUT-IN-IN-OUT-OUT-OUT-IN SLAVE CONFIGURATION.	
	OUT		DDRB,R16
	LDI		R16,0B01001010	;ENVIO J
	OUT		SPDR,R16	
	LDI		R16,0B00000000
	OUT		SPSR,R16		;SPIE=F	SP=F _ _ _ SPI2X=0 _ _
	LDI		R16,0B11000000	;SPIE=1 SPE=1 DORD=0 MSTR=0 CPOL=0 CPHA=0 SPR1SPR0=00 (FOSC/4)
	OUT		SPCR,R16	
	SBI		PORTB,3
	SEI

END:
	RJMP	END
