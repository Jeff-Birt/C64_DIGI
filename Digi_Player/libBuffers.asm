;===============================================================================
;* Simple buffers in 6502 asm                                                  *
;===============================================================================

*=$C000

;*******************************************************************************
;* Circular buffer, using 256 bytes as gives automatic wrap around when inc'ing
; Tail = Head -> buffer empty
; Tail = (Head + 1) -> buffer full (i.e. inc head would hit tail)
; 
; outBufFlag = 0 -> partial, outBufFlag = 1 -> empty, outBufFlad = 2 -> full
;*******************************************************************************

outBuf          bytes 256       ; Circular output byte buffer

;*******************************************************************************
; *OutBufInit,  initialize pointerrs used by outBuf
; pointers in zero page, defined in memoryMap.asm
;*******************************************************************************
OutBufInit
        lda #$00                ; $00 = head at start
        sta outBufHead          ; head points to next free byte
        lda #$00                ; $00 = tail at start
        sta outBufTail          ; tail points to next byte to read
        rts


;*******************************************************************************
; *OutBufFull may not need eventually
; returns X/Z=0 if buffer is full
;*******************************************************************************
OutBufFull
        ldx #$00                ; (2) preload fail return code
        ldy outBufHead          ; (3) get current value of head pointer
        iny                     ; (2) increment it one
        cpy outBufTail          ; (3) compare to tail pointer
        beq @done               ; (3) if new value same as tail = already full
        ldx #$01                ; (2) X=1 means not full
@done
        rts                     ; (6) 21 cycles total

;*******************************************************************************
; *OutBufWrite read next byte from outBuf, value to save passed in A,
; X=0, Z=1 returned if buffer full (fail), caller can branch on state of X/Z
; could have used C flag but VICE seems to have a bug in debug mode
; Only uses 255 out of 256 bytes, 1 byte padding between head and tail
;*******************************************************************************
defm    OutBufWrite
        ldx outBufHead          ; (3) get current value of head pointer
        inx                     ; (2) increment it one, does not affect C
        cpx outBufTail          ; (3) compare to tail pointer
        beq wdone               ; (3) tail=head is full, if Z=0 then C=1
        dex                     ; (2) need X back to where it was
        sta outBuf,x            ; (6) store value, index to X
        inx                     ; (2) increment it one, again!
        stx outBufHead          ; (3) save incremented head pointer
        ldx #$01                ; (2) so BNE/BEQ can be used
wdone                           ; (24 if a macro)
        endm


;*******************************************************************************
; *OutBufRead, uses register A, X
; read next byte from outBuf, value returned in A,
; X=0, Z=1 returned buffer empty (fail), X=1 success
; could have used C flag but VICE seems to have a bug in debug mode
;*******************************************************************************
defm    OutBufRead
        ldx outBufTail          ; (3) grab the tail pointer
        cpx outBufHead          ; (3) comapre to head pointer
        beq rdone               ; (3) Z=0 empty, if Z=0 then C=1
        lda outBuf,x            ; (6) load value, X indexed
        inx                     ; (2) inc tail pointer, does not affect C
        stx outBufTail          ; (3) save inremented tail pointer
        ldx #$01                ; (2) so BNE/BEQ can be used
rdone                           ; (20 if a macro)
        endm


