INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM
SECTION "Header", ROM0[$00] 
	; basic timer test. 
	; Load timer that incremetns
	; every 16 clocks. Remove
	; last nop. Result is 
	; TIMA = 2 or TIMA = 3
	ld a, $00
	ldh [$05], a	; TIMA = 0
	ldh [$06], a 	; TMA = 0
	ld a, $05
	ldh [$07], a	; TAC = 110

	; clocks for a = n
	; 8 + (n * 12 + 4)
	ld a, 1
loop:
	dec a			; 4 clocks
	jr nz, loop		; 12 / 8 clocks
	nop 			; 4
	nop				; 4
	nop				; 4
	nop
	die	
