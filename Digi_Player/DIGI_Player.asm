
SID     = $D400         ; base address of SID chip
;start   = DATASTART     ; start of sample
;end     = DATASTOP      ; end of sample
freq    = $80           ; CIA NMI timer delay
ptr     = $fd           ; pointer to current byte of sample

*= $1000

;-------------------------------------------------------------------------------
; Initialize DIGI_Player

        ; switch out roms while sample playing
        LDA #$35                ;
        STA $01                 ; 6510 banking register

        ; disable interrupts
        LDA #$00                ; was $F7 in the_c64_digi.txt
        STA $DD0D               ; ICR CIA #2
        LDA $DD0D               ; read acks any pending interrupt
        ;SEI                    ; disables maskable interrupts

        ; initialize SID
        LDA #$00                ; zeros out all SID registers
        LDX #$00                ;
@SIDCLR                         ;
        STA SID,x               ; 
        INX                     ;
        BNE @SIDCLR             ;

        ; SID voices modulated too, increases volume on 8580 SIDs
        LDA #$00                ; 
        STA SID+$05             ; voice 1 Attach/Decay 
        LDA #$F0                ;
        STA SID+$06             ;         Systain/Release 
        LDA #$01                ;
        STA SID+$04             ;         ctrl 
        LDA #$00 
        STA SID+$0C             ; voice 2 Attach/Decay 
        LDA #$F0                ;
        STA SID+$0D             ;         Systain/Release 
        LDA #$01                ;
        STA SID+$0B             ;         ctrl 
        LDA #$00        
        STA SID+$13             ; voice 3 Attach/Decay 
        LDA #$F0                ;
        STA SID+$14             ;         Systain/Release 
        LDA #$01                ;
        STA SID+$12             ;         ctrl 
        LDA #$00 
        STA SID+$15             ; filter  lo 
        LDA #$10                ;
        STA SID+$16             ; filter  hi 
        LDA #$F7                ;
        STA SID+$17             ; filter  voices+reso 

         ; blank screen, don't really have to though
;         lda $D011      ; VICII control register 1
;         and #$EF
;         sta $D011 

        ; point to our player routine
        LDA #<NMI_HANDLER       ; set NMI handler address low byte
        STA $FFFA               ;
        LDA #>NMI_HANDLER       ; set NMI handler address low byte
        STA $FFFB               ;

        ; set pointer to beginning address of sample
        LDA #<DATASTART         ; low byte
        STA ptr                 ;
        LDA #>DATASTART         ; high byte
        STA ptr+1               ;

        ; load a sample and determine if it is RLE, byte = $00 is RLE marker
        ; when ptr is incremented here we do not check for samepl endless
        ; as we can assume the sample is more than a few bytes long  
        LDA #$01                ; flag should start at 1
        STA flag                ; to denote a non RLE byte
        LDY #$00                ; set offset to first byte
        LDA (ptr),y;            ; load in first sample byte
        STA sample              ; save just in case it is not RLE
        BNE notRLE              ; skip ahead if not RLE marker of $00

        ; here we decode an RLE pair
        INC ptr                 ; inc the sample pointer
        BNE @skip               ; if we did not roll over low byte skip ahead
        INC ptr+1               ; inc the high byte
@skip     
        LDA (ptr),y             ; load RLE byte in
        TAX                     ; save a copy of RLE byte
        LSR A                   ; shift count down to low nibble
        LSR A                   ; encoded count is actual - 1
        LSR A                   ; additional copy of value in high nibble
        LSR A                   ; gives us proper # for playback
        STA flag                ; save count
        TXA                     ; get back our original byte
        AND #$0F                ; mask off high nibble
        STA sample              ; save our low nibble only
        CLC                     ; make sure carry bit clear
        ROL                     ; shift low nibble up to high nibble
        ROL                     ;
        ROL                     ;
        ROL                     ; now we have copy of low nibble in high nibble
        ORA sample              ; OR to combine both nibbles
        STA sample              ; store back to sample byte address  

; *** old first sample code
;        LDY #$00                ; zero out flag used for
;        STY flag                ; indicating which nibble to play
;        LDA (ptr),y             ; loads first sample byte
;        STA sample              ; save to temp storage address

notRLE
        INC ptr                 ; inc the saple pointer
        BNE @skip               ; if we did not roll over low byte skip ahead
        INC ptr+1               ; inc the high byte

@skip
        ; setup CIA #2, do last as it starts interrupts!
        LDA #<freq              ; interrupt freq
        STA $DD04               ; TA LO
        LDA #>freq              ;
        STA $DD05               ; TA HI

        LDA #$81                ; ICR set to TMR A underflow
        STA $DD0D               ; ICR CIA #2
        LDA #$11                ;
        STA $DD0E               ; CRA interrupt enable

endless 
        RTS                     ; can RTS or
        ;JMP endless             ; endless loop for demo purposes


;-------------------------------------------------------------------------------
; NMI handler routine, plays one 4bit sample per pass

NMI_HANDLER        
         ; start with saving register state
         PHA                    ; 3-will restore when returning
         TXA                    ; 2-from interrupt handler 
         PHA                    ; 3-
         TYA                    ; 2-
         PHA                    ; 3-(13)

         ; play 4-bit sample, first sample byte saved during Init
         LDA sample             ; 4-load sample byte
         ORA #$10               ; 2-make sure we don't kill filter settings
         AND #$1F               ; 2-git rid of any dangling high bits
         STA SID+$18            ; 4-save to SID volume regsiter
         STA $D020              ; 4-(18)change border color for something to look at
         ;LDA $DD0D              ; clear NMI

;         ;every other NMI do *1 or *2
;         LDA flag               ; if flag==0 we should play upper nibble next
;         BNE lower              ; so skip ahead to load new byte

         ; flag is now a counter of how many times to play the lower nibble
         ; if flag == 0 load next byte
         ; dec the flag counter, if flag is no zero play upper nibble
         ; otherwise if flag > 0 exit NMI 
         LDA flag               ; 4-if flag==0 we should play upper nibble next
         BEQ loadByte           ; 2-load a new byte from sample data
         DEC flag               ; 6-decrement count
         LDA flag               ; 4-get current count
         BEQ upperNibble        ; 2-we are ready for upper nibble now
         JMP exit               ; 3-(21)done for this pass
     
upperNibble    
         LDA sample             ; 4-*1 shift upper nibble down
         LSR a                  ; 2-
         LSR a                  ; 2-
         LSR a                  ; 2-
         LSR a                  ; 2-
         STA sample             ; 4-store it back to play next pass
         JMP exit               ; 3-(19)all done for this pass

;lower
loadByte
         LDY #$00                ; 2-set offset to first byte
         LDA (ptr),y;            ; 5-load in first sample byte
         STA sample              ; 4-save just in case it is not RLE
         BEQ rle                 ; 2-if $00 is RLE marker, go to decoder
         LDA #$01                ; 2-set the flag to 1
         STA flag                ; 4-for non-RLE encoded
         INC ptr                 ; 6-inc the saple pointer
         BNE checkend            ; 2-if we did not roll over low byte skip ahead
         INC ptr+1               ; 6-inc the high byte
         JMP checkend            ; 3-(36)skip the REL decoder

rle      ; here we decode an RLE pair
         INC ptr                 ; 6-inc point to next sample byte
         BNE @skip               ; 2-if we did not roll over low byte skip ahead
         INC ptr+1               ; 6-(14)inc the high byte
@skip

         LDA (ptr),y             ; 5-load RLE byte in
         TAX                     ; 2-save a copy of RLE byte
         LSR A                   ; 2-shift count down to low nibble
         LSR A                   ; 2-encoded count is actual - 1
         LSR A                   ; 2-additional copy of value in high nibble
         LSR A                   ; 2-gives us proper # for playback
         STA flag                ; 4-save count
         TXA                     ; 2-get back our original byte
         AND #$0F                ; 2-mask off high nibble
         STA sample              ; 4-save our low nibble only
         CLC                     ; 2-make sure carry bit clear
         ROL                     ; 2-shift low nibble up to high nibble
         ROL                     ; 2-
         ROL                     ; 2-
         ROL                     ; 2-now we have copy of low nibble in high nibble
         ORA sample              ; 4-OR to combine both nibbles
         STA sample              ; 4-(45)store back to sample byte address

; *** original load new sample byte
;         LDY #0                 ; *2 get a new packed sample byte
;         LDA (ptr),y            ;       
;         STA sample             ; save to temp location
;         INC ptr                ; inc point to next sample byte
;         BNE checkend           ; did we roll low byte over to zero?
;         INC ptr+1              ; if so inc the high byte of pointer too
         
checkend 
         LDA ptr                ; 4-if not at end of sample exit/return from NMI
         CMP #<DATASTOP         ; 4-low byte
         BNE exit               ; 2-
         LDA ptr+1              ; 4-high byte
         CMP #>DATASTOP         ; 4-
         BNE exit               ; 2-(20)

         ; this block for continious play
;         LDA #<DATASTART        ; if we are at the end of the sample
;         STA ptr                ; we point back to beginning for endless loop
;         LDA #>DATASTART        ;
;         STA ptr+1              ;

         ; this block for single play, turn off NMI interrupt
         LDA #$00               ; 2-turn off NMI
         STA $DD0E              ; 4-timer A stop-CRA, CIA #1 DC0E
         LDA #$4F               ; 2-disable all CIA-2 NMIs 
         STA $DD0D              ; 4-ICR - interrupt control / status
         LDA $DD0D              ; 4-(18)sta/lda to ack any pending int

         LDA #$37               ; 2-reset kernal banking
         STA $01                ; 3-(5)

;exit     
;         LDA flag               ; toggle hi/low nibble flag and exit NMI
;         EOR #1                 ;
;         STA flag               ;
exit     LDA $DD0D              ; 4-clear NMI
         PLA                    ; 3-restore state
         TAY                    ; 2-
         PLA                    ; 3-
         TAX                    ; 2-
         PLA                    ; 3-
         RTI                    ; 6-(23)return from this pass of NMI

         ; Sample's lower nybble holds the 4-bit sample to played on the
         ; next NMI. The upper nybble holds the next nybble to be
         ; played on "odd" NMIs, and is undefined on "even" NMIs.
sample   
        BYTE $00

         ; flag simply toggles between 0 and 1 - used to decide whether
         ; to play upper or lower nybble
flag     
        BYTE $00



