
flagSeed = $55           ; flag seed, 8kHz
freq     = $80           ; CIA NMI timer delay, 8kHz
;flagSeed = $00           ; flag seed, 4Hz
;freq    = $100          ; CIA NMI timer delay, 4kHz


;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (2064)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $34
        byte $30, $39, $36, $29, $00, $00, $00

        ; Our code starts at $0810 (2064 decimal)
        ; after the 15 bytes for the BASIC loader

;===============================================================================



*= $1000

;-------------------------------------------------------------------------------
; Initialize DIGI_Player

        PHA                     ; We need to save both A
        TXA                     ;
        PHA                     ; and X as we use them

        ; disable interrupts
        LDA #$00                ; was $7f in the_c64_digi.txt
        STA $DC0D               ; ICR CIA #2
        STA $DD0D               ; read acks any pending interrupt
        LDA $DC0D
        LDA $DD0D
        SEI                    ; disables maskable interrupts

        ; switch out kernal rom while sample playing
        LDA #$35                ;
        STA $01                 ; 6510 banking register

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

        ; point to our player routine
        LDA #<NMI_HANDLER       ; set NMI handler address low byte
        STA $FFFA               ;
        LDA #>NMI_HANDLER       ; set NMI handler address hi byte
        STA $FFFB               ;

        LDA #<DATASTART         ; low byte
        STA loadnew+1           ;
        LDA #>DATASTART         ; high byte
        STA loadnew+2           ;

        LDA #flagSeed           ; initialize flag used for
        STA flag                ; indicating which nibble to play
        LDA DATASTART           ; loads first sample byte
        STA sample              ; save to temp storage address
        INC loadnew+1           ; # - increment self-mod pointer LSB

        ; setup CIA #2, do last as it starts interrupts!
        LDA #<freq              ; interrupt freq
        STA $DD04               ; TA LO
        LDA #>freq              ;
        STA $DD05               ; TA HI

        LDA #$81                ; ICR set to TMR A underflow
        STA $DD0D               ; ICR CIA #2
        LDA #$11                ;
        STA $DD0E               ; CRA interrupt enable

        PLA                     ; Let's get our X and
        TAX                     ; 
        PLA                     ; A that we saved
endless        
        RTS                     ; can RTS or
        ;JMP endless             ; endless loop for demo purposes


;-------------------------------------------------------------------------------
; NMI handler routine, plays one 4bit sample per pass
; Path A -> Play Lower, shift upper down. 3+19+13+23=58 cycles
; Path B -> Play upper, load new sample. 3+19+8+25=55 cycles
; Path C -> Play upper. load sample, new page. 3+19+8+14+21=65 cycles
; Sample's lower nybble holds the 4-bit sample to played on the "even" NMIs
; The upper nybble holds the next nybble to be played on "odd" NMIs
NMI_HANDLER        
        ; start with saving state       
        PHA                     ; 3- (3) will restore when returning

        ; play 4-bit sample, first sample byte saved during Init
        LDA sample              ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (19)clear NMI

        ; flag init to $AA or $55, We shift alternating pattern though flag byte
        ASL flag                ; 5- shift patten left thru flag byte
        BCC loadnew             ; 2-3 
        INC flag                ; 5 (8-13) so skip ahead to load new byte
   
shftupr
        LDA sample              ; 3- *1 shift upper nibble down
        LSR a                   ; 2-
        LSR a                   ; 2-
        LSR a                   ; 2-
        LSR a                   ; 2-
        STA sample              ; 3- store it back to play next pass

        PLA                     ; 3- local exit code is smaller and 
        RTI                     ; 6- (23) faster than jumps/branches

        ; loadnew+1,+2 is self-modifying ptr to sample, gets set in init
loadnew
        LDA $FFFF               ; 3 -self-mod pointer to sample
        STA sample              ; 3- save to temp location
        INC loadnew+1           ; 5 - increment self-mod pointer LSB
        BEQ @nextPage           ; 2-3- (??) did we cross a page?

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (14-25)faster than jumps/branches

@nextPage
        ; this is only executed every 512 samples
        LDA loadnew+2           ; 3- increment self-mod pointer MSB
        ADC #$01                ; 2- carry is clear from flag test
        CMP #>DATASTOP          ; 2- are we done?
        BEQ @stop               ; 2-3- yes, then stop
        STA loadnew+2           ; 3- no, save new MSB

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (18-21)faster than jumps/branches

@stop
        LDA #$08                ; 2- turn off NMI
        STA $DD0E               ; 4- timer A stop-CRA, CIA #1 DC0E
        LDA #$4F                ; 2- disable all CIA-2 NMIs 
        STA $DD0D               ; 4- ICR - interrupt control / status
        LDA $DD0D               ; 4- (16) sta/lda to ack any pending int

        LDA #$37                ; 2- reset kernal banking
        STA $01                 ; 3- (5)
        
        PLA                     ; 3- local exit code is smaller and
        CLI
        RTI                     ; 6- faster than jumps/branches






