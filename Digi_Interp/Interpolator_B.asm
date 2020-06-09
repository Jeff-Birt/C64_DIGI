;///////////////////////////////////////////////////////////////////////////////
; A try at an interpolating DIGI Player

n0L = $92
n0M = $93
n0H = $96
ctr = $97

freq     = $90           ; CIA NMI timer delay, 8kHz

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

        PHA                     ; save A as we use it
        TXA                     ; save X too
        PHA                     ;

        LDA #$00                ; was $7f in the_c64_digi.txt
        STA $DC0D               ; ICR CIA #2
        STA $DD0D               ; read acks any pending interrupt
        LDA $DC0D
        LDA $DD0D
        SEI                     ; disables maskable interrupts

        LDA #$35                ; switch out kernal rom while sample playing
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

;         ; blank screen, don't really have to though
;         LDA $D011      ; VICII control register 1
;         AND #$EF
;         STA $D011 

        ; set up the various ''pointers'
        LDA #<NMI_HANDLER      ; point to our first NMI handler 
        STA $FFFA               ; NMI handler address low byte
        LDA #>NMI_HANDLER      ; 
        STA $FFFB               ; NMI handler address hi byte

        LDA #<DATASTART         ; Set up self modifying pointer to sample data
        STA loadnew+1           ; to current low byte
        LDA #>DATASTART         ; Set up self modifying pointer to sample data
        STA loadnew+2           ; to current high byte

        LDA #<DATASTART         ; Set up self modifying pointer to sample data
        STA peeknext+1          ; to next low byte
        INC peeknext+1
        INC peeknext+1
        LDA #>DATASTART         ; Set up self modifying pointer to sample data
        STA peeknext+2          ; to next high byte
        
        lda DATASTART           ; get first sample byte, store to 
        sta n0L                 ; low nibble zero page spot
        INC loadnew+1           ; increment self-mod pointer LSB

        ; setup CIA #2, do last as it starts interrupts!
        LDA #<freq              ; interrupt freq
        STA $DD04               ; TA LO
        LDA #>freq              ;
        STA $DD05               ; TA HI

        LDA #$81                ; ICR set to TMR A underflow
        STA $DD0D               ; ICR CIA #2
        LDA #$11                ;
        STA $DD0E               ; CRA interrupt enable

        PLA                     ; Let's get back out X
        TAX                     ;
        PLA                     ; and A we saved

endless 
        RTS                     ; can RTS or
        ;JMP endless             ; endless loop for demo purposes

NMI_HANDLER
        ; play n0L branch to correct handler 0-3
        PHA                     ; 3- (3) will restore when returning

        LDA n0L                 ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (19) clear NMI
        
        LDA #$01                ; 2-
        BIT ctr                 ; 3- (5)
        BPL ISR_2               ; 2-3 (8branch2)
        BNE ISR_1               ; 2-3 (9thru-10branch1)
        ; total cycles 3+19+9 = 31 thru
        ; total cycles 3+19+8 = 30 branch2
        ; total cycles 19+10 = 31 branch1

ISR_0
        ; ISR #0 - calc mid point of hiA-loA save to lo, move hi to mid
        INC ctr                 ; 5-
        lda n0L                 ; 3- n0L has data in upper nibble
        lsr                     ; 2- shift to lower nibble position
        lsr                     ; 2- doing this here to even out
        lsr                     ; 2- cycles in ISRs
        lsr                     ; 2-
        sta n0M                 ; 3- save mid nibble store
        lda n0L                 ; get origianl byte again
        and #$0F                ; mask off upper nibble
        clc                     ; 2- clear carry before add
        adc n0M                 ; 3- add low nibble to high nibble
        lsr                     ; 2- /2 to get an average
        sta n0L                 ; 3- (25) is played on next ISR as lo 

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)
        ; total cycles 31+29+9 = 69 31+34+9 = 74

ISR_1
        ; ISR #1, play lo, move mid to lo
        INC ctr                 ; 5-
        lda n0M                 ; 3- move mid->low
        sta n0L                 ; 3- (11)move mid->low

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9) 
        ; total cycles 31+11+9 = 51

ISR_2
        ; ISR #2, play lo, calc mid point of loB-hiA save to lo
        BNE ISR_3               ; 2-3
        INC ctr                 ; 5-

peeknext 
        lda $FFFF               ; 3- peek next sample byte via self mod. pointer
        and #$0F                ; 2- keep only the low nibble of next sample               
        clc                     ; 2- clear carry before adding next low nibble 
        adc n0L                 ; 3- loB to previuos hi nibble hiA
        lsr                     ; 2- /2 to get an average midpoint value
        sta n0L                 ; 3- (7) save it to play next as n0L

        INC peeknext+1          ; 5 - increment self-mod pointer LSB
        BEQ nextPeekPage        ; 2-3 (7-8) did we cross a page?
        
        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)

nextPeekPage
        INC peeknext+2          ; 3- increment self-mod pointer MSB

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)


ISR_3
        ; ISR #3, load sample B, separate hi & lo nibbles
        LDA #$FE                ; 2- rest out routint counter/index
        STA ctr                 ; 3- (5)

loadnew ; maybe get rid of use of X so we don't ahve to save its state
        LDA $FFFF               ; 3 -self-mod pointer to sample
        sta n0L                 ; 3- save low nibble

incptr
        INC loadnew+1           ; 5 - increment self-mod pointer LSB
        BEQ @nextPage           ; 2-3- (7thru-8brach) did we cross a page?

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (16thru-8branch)
        ; total cycles 33+5+17+16 = 71, 33+5+5+16 = 59

@nextPage
        ; this is only executed every 512 samples
        LDA loadnew+2           ; 3- increment self-mod pointer MSB
        ADC #$01                ; 2- carry is clear from flag test
        CMP #>DATASTOP          ; 2- are we done?
        BEQ @stop               ; 2-3- yes, then stop
        STA loadnew+2           ; 3- no, save new MSB

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (21thru-)
        ; total cycles 33+5+17+8+21 = 84, 33+5+5+8+21 = 72

@stop
        LDA #$00                ; 2- turn off NMI
        STA $DD0E               ; 4- timer A stop-CRA, CIA #1 DC0E
        LDA #$4F                ; 2- disable all CIA-2 NMIs 
        STA $DD0D               ; 4- ICR - interrupt control / status
        LDA $DD0D               ; 4- (16) sta/lda to ack any pending int

        LDA #$37                ; 2- reset kernal banking
        STA $01                 ; 3- (5)
        
        PLA                     ; 3- local exit code is smaller and
        CLI
        RTI                     ; 6- faster than jumps/branches








        