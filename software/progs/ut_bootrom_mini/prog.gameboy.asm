INCLUDE "hardware.inc"

SECTION "Header", ROM0[$00] 
	LD A,$01		; $00fc
	LDH [$50], A	; $00fe	;turn off DMG rom