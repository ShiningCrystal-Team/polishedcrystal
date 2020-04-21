; Small routines and data can fit in the unused rst and interrupt vector space.


; rst vectors

SECTION "rst00 EntryPoint", ROM0[$0000]
EntryPoint::
	di
	jp Rst0Crash

PushWindow::
	farjp _PushWindow


SECTION "rst08 FarCall", ROM0[$0008]
FarCall::
	jp RstFarCall

PopAFBCDEHL::
	pop af
PopBCDEHL::
	pop bc
	pop de
	pop hl
	ret


SECTION "rst10 Bankswitch", ROM0[$0010]
Bankswitch::
	ldh [hROMBank], a
	ld [MBC3RomBank], a
	ret

_de_::
	push de
DoNothing::
	ret


SECTION "rst18 AddNTimes", ROM0[$0018]
AddNTimes::
	jp _AddNTimes

FarCopyColorWRAM::
	ld a, BANK("GBC Video")
	; fallthrough

FarCopyWRAM::
	call StackCallInWRAMBankA
	; fallthrough


SECTION "rst20 CopyBytes", ROM0[$0020]
CopyBytes::
	jp _CopyBytes

GetFarByte::
; retrieve a single byte from a:hl, and return it in a.
	call StackCallInBankA

.Function:
	ld a, [hl]
	ret


SECTION "rst28 ByteFill", ROM0[$0028]
ByteFill::
	jp _ByteFill

GetFarWRAMByte::
	call StackCallInWRAMBankA

.Function:
	ld a, [hl]
	ret


SECTION "rst30 PlaceString", ROM0[$0030]
PlaceString::
	jp _PlaceString

SwapHLDE::
	push de
	ld d, h
	ld e, l
	pop hl
	ret


SECTION "rst38 Predef", ROM0[$0038]
Predef::
	jp _Predef

IsAPokemon::
; For functions using EGG as sentinel, use "and a" instead (EGG is $ff)
; Returns carry if species a is not a Pokemon (including $ff)
	inc a
	cp 2 ; sets carry for $0 (inc'ed to $1) and $ff (inc'ed to $0)
	dec a
	ret


; Game Boy hardware interrupts

SECTION "vblank", ROM0[$0040]
	jp VBlank

ItemIsMail::
	ld a, d
	cp FLOWER_MAIL
	ccf
	ret


SECTION "lcd", ROM0[$0048]
	jp LCD

GetMemCGBLayout::
	xor a ; CGB_RAM
GetCGBLayout::
	farjp LoadCGBLayout


SECTION "timer", ROM0[$0050]
; TIMER is never enabled

	ds 1 ; unused

ExitMenu::
	push af
	farcall _ExitMenu
	pop af
	ret


SECTION "serial", ROM0[$0058]
	jp Serial

CheckOnWater::
	call GetPlayerStandingTile
	dec a ; cp WATER_TILE
	ret


SECTION "joypad", ROM0[$0060]
; JOYPAD is never enabled


SECTION "High Home", ROM0[$0060]

	ds 1 ; unused

INCLUDE "home/jumptable.asm"
INCLUDE "home/sine.asm"
INCLUDE "home/delay.asm"
INCLUDE "home/gfx2.asm"


SECTION "Header", ROM0[$0100]

Start::
	nop ; no-optimize nops
	jp _Start

; rgbfix patches the cartridge header here
	ds $0150 - @, $00
