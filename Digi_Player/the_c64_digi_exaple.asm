
start    = $1400        ; start of sample
end      = $7cff        ; end of sample
freq     = 141          ; CIA NMI timer delay
ptr      = $fd          ; pointer to current byte of sample

*= $1000

         ;disable interrupts
         lda #$7f       ; same effect as writing $00
         sta $dc0d      ; ICR CIA #1
         sta $dd0d      ; ICR CIA #2
         lda $dc0d      ; write/read to clear
         lda $dd0d      ;
         sei            ; disables interrupts

         ;blank screen, don't really have to though
         lda $d011      ; VICII control register 1
         and #255-16
         sta $d011

         ;switch out roms
         lda #$35
         sta 1

         ;point to our player routine
         lda #<nmi      ; this is setting NMI address
         sta $fffa
         lda #>nmi
         sta $fffb

         ;initialize player
         lda #<start    ; beginning of digi
         sta ptr
         lda #>start
         sta ptr+1

         ldy #0         ; zero out flag used for
         sty flag       ; indicating which nibble to play
         lda (ptr),y    ; loads first sample byte
         sta sample     ; save to temp storage

         ;setup CIA #2
         lda #<freq     ; interrupt freq
         sta $dd04      ; TA LO
         lda #>freq
         sta $dd05      ; TA HI

         lda #%10000001 ; ICR set to TMR A underflow
         sta $dd0d

         lda #%00010001
         sta $dd0e      ; CRA interrupt enable

endless  jmp endless    ; endless loop for demo purposes


; beginning of NMI routine, plays one 4bit sample per pass
nmi     
         pha            ; save the state of things
         txa
         pha
         tya
         pha

         ;play 4-bit sample
         lda sample     ; first sample byte saved as part of player start
         and #$0F       ; and #$0F so we don't futz with filters
         sta $d418      ; SID volume regsiter

         lda $dd0d      ; clear NMI source
         inc $d020      ; changes border color, something to look at

         ;every other NMI do 1) or 2):
         lda flag       ; if flag==0 we just played upper nibble
         bne lower      ; so skip ahead
         
upper    lda sample     ;1 ) shift upper nibble down
         lsr a
         lsr a
         lsr a
         lsr a
         sta sample     ; store it back to play next pass
         jmp exit       ; all done for this pass

lower    ldy #0         ; 2) get a new packed sample byte
         lda (ptr),y    ;
         sta sample     ; save to temp location
         inc ptr        ; inc point to next sample byte
         bne checkend   ; did we roll over to zero?
         inc ptr+1      ; if so inc the high byte of pointer too

         
checkend lda ptr        ; if end of sample point to beginning again
         cmp #<end      ; low byte
         bne exit
         lda ptr+1      ; high byte
         cmp #>end
         bne exit       ;

         lda #<start    ; we point back to beginning for endless loop
         sta ptr        ; would not need to do this if playing sampel once
         lda #>start
         sta ptr+1      ;

exit     lda flag       ; toggle hi/low nibble flag and exit NMI
         eor #1
         sta flag       ;

         pla            ; restore state
         tay
         pla
         tax
         pla
         rti            ; return from this pass of NMI

         ; Sample's lower nybble holds the 4-bit sample to played on the
         ; next NMI. The upper nybble holds the next nybble to be
         ; played on "odd" NMIs, and is undefined on "even" NMIs.
sample   .byte 0

         ; flag simply toggles between 0 and 1 - used to decide whether
         ; to play upper or lower nybble
flag     .byte 0

