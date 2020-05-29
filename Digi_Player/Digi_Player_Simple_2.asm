;SID     = $D400         ; base address of SID chip
;start   = DATASTART     ; start of sample
;end     = DATASTOP      ; end of sample
;freq    = $80           ; CIA NMI timer delay
;ptr     = $fd           ; pointer to current byte of sample

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

        LDY #$00                ; zero out flag used for
        STY flag                ; indicating which nibble to play
        LDA (ptr),y             ; loads first sample byte
        STA sample              ; save to temp storage address

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
        ; start with saving state
        PHA                     ; 3- will restore when returning
        TYA                     ; 2- from interrupt handler
        PHA                     ; 3- (8) 

        ; play 4-bit sample, first sample byte saved during Init
        LDA sample              ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color for something to look at
        LDA $DD0D               ; 4- (19)clear NMI

         ;every other NMI do *1 or *2
        LDA #$01                ; 2- if flag!=0 we just played upper nibble
        EOR flag                ; 3- 
        STA flag                ; 3-
        BNE lower               ; 2-3 (10-11) so skip ahead to load new byte

upper   LDA sample              ; 3- *1 shift upper nibble down
        LSR a                   ; 2-
        LSR a                   ; 2-
        LSR a                   ; 2-
        LSR a                   ; 2-
        STA sample              ; 3- store it back to play next pass
        JMP exit                ; 3- (17) all done for this pass

lower   LDY #$0                 ; 2- *2 get a new packed sample byte
        LDA (ptr),y             ; 5-      
        STA sample              ; 3- save to temp location
        INC ptr                 ; 5- inc point to next sample byte
        BNE checkend            ; 2-3 did we roll low byte over to zero?
        INC ptr+1               ; 5- (22-23) if so inc the high byte of ptr too
   
checkend 
        LDA ptr                 ; 3- if not @ end of sample exit/return from NMI
        CMP #<DATASTOP          ; 4- low byte
        BNE exit                ; 2-3 (10)
        LDA ptr+1               ; 3- high byte
        CMP #>DATASTOP          ; 4 
        BNE exit                ; 2-3 (18-19)

         ; when done with sample, turn off NMI interrupt
        LDA #$00                ; 2- turn off NMI
        STA $DD0E               ; 4- timer A stop-CRA, CIA #1 DC0E
        LDA #$4F                ; 2- disable all CIA-2 NMIs 
        STA $DD0D               ; 4- ICR - interrupt control / status
        LDA $DD0D               ; 4- (16) sta/lda to ack any pending int
 
        LDA #$37                ; 2- reset kernal banking
        STA $01                 ; 3- (5)

exit     
        PLA                     ; 3- restore state
        TAY                     ; 2- 
        PLA                     ; 3-
        RTI                     ; 6- (14) return from this pass of NMI
                                ; 68 *1, 84-85,93-94 *2

         ; Sample's lower nybble holds the 4-bit sample to played on the
         ; next NMI. The upper nybble holds the next nybble to be
         ; played on "odd" NMIs, and is undefined on "even" NMIs.



