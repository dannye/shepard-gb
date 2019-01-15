include "constants.asm"


section "Main WRAM", wram0

wFrequencyTimer: ds 1


section "Main", rom0

Main::
	call .Setup
.loop
	call WaitVBlank
	call IncFrequency
	jr .loop

.Setup:
	call InitSound
	put [wFrequencyTimer], 0
	ret

IncFrequency:
	call GetFrequencyPair1
	ld a, [wFrequencyTimer]
	call Lerp
	ld d, h
	ld e, l
	call SetFrequency1

	call GetFrequencyPair2
	ld a, [wFrequencyTimer]
	call Lerp
	ld d, h
	ld e, l
	call SetFrequency2

	call GetFrequencyPair3
	ld a, [wFrequencyTimer]
	call Lerp
	ld d, h
	ld e, l
	call SetFrequency3

	ld a, [wFrequencyTimer]
	add 2
	ld [wFrequencyTimer], a
	jnz .done
	call NextNote
.done
	ret
