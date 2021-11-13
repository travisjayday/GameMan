INCLUDE "hardware.inc"
MACRO die 
	ld b, b
	nop
ENDM

SECTION "Shadow OAM", WRAM0,ALIGN[8]

wShadowOAM:
  ds 4 * 40 ; This is the buffer we'll write sprite data to

SECTION "Header", ROM0[$00] 
  jp  main
CopyDMARoutine:
  ld  hl, DMARoutine
  ld  b, DMARoutineEnd - DMARoutine ; Number of bytes to copy
  ld  c, LOW(hOAMDMA) ; Low byte of the destination address
.copy
  ld  a, [hli]
  ldh [c], a
  inc c
  dec b
  jr  nz, .copy
  ret

DMARoutine:
  ldh [$46], a
  ld  a, 40
.wait
  dec a
  jr  nz, .wait
  ret
DMARoutineEnd:

PopulateShadowOAM:
	ld hl, wShadowOAM
	ld a, 160
.loop:
  push af
  ld a, b
	ld [hl+], a
  inc b
  pop af
	dec a
	jr nz, .loop
	ret

// Run two dma transfers one after another
main: 
	call CopyDMARoutine
  ld b, $50
	call PopulateShadowOAM
	ld a, HIGH(wShadowOAM)
	call hOAMDMA
  ld b, $0
	call PopulateShadowOAM
	ld a, HIGH(wShadowOAM)
	call hOAMDMA
	die

SECTION "OAM DMA", HRAM

hOAMDMA::
  ds DMARoutineEnd - DMARoutine ; Reserve space to copy the routine to
