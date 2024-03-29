INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
DEF NR52 = $26
DEF NR51 = $25
DEF NR50 = $24
DEF NR21 = $16
DEF NR22 = $17
DEF NR23 = $18
DEF NR24 = $19
DEF NR10 = $10
DEF NR11 = $11
DEF NR12 = $12
DEF NR13 = $13
DEF NR14 = $14

MACRO SET_REG
	ld a, \2
	ldh [\1], a
ENDM

SECTION "Header", ROM0[$0] 
	; Enable sound circuits
	SET_REG NR52, $80
	
	; Set Volume
	SET_REG NR50, $77

	; Enable Channel 2
	SET_REG NR51, $FF

raise:
	SET_REG NR21, $80
	SET_REG NR22, $F1
	SET_REG NR23, $d6
	SET_REG NR24, $86

	ld hl, $ffff
loop:
	dec hl
	xor a, a
	or a, h
	or a, l
	jp nz, loop

	SET_REG NR21, $80
	SET_REG NR22, $09
	SET_REG NR23, $d6
	SET_REG NR24, $86


	ld hl, $ffff
loop2:
	dec hl
	xor a, a
	or a, h
	or a, l
	jp nz, loop2

	jp raise

	die	
