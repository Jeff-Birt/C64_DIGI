;///////////////////////////////////////////////////////////////////////////////
; A try at an interpolating DIGI Player

n0L = $92
n0M = $93
;n0H = $96
ctr = $97

freq     = $80           ; CIA NMI timer delay, 8kHz

;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (4096)

        byte $0E, $08, $0A, $00, $9E, $20, $28, $34
        byte $30, $39, $36, $29, $00, $00, $00

        ; Our code starts at $0810 (2064 decimal) NOT TRUE!
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

        ; initialize all SID registers
        LDA #$00                ; zeros out all SID registers
        LDX #$00                ;
@SIDCLR                         ;
        STA SID,x               ; 
        INX                     ;
        BNE @SIDCLR             ;

        ; SID voices modulated too, increases volume on 8580 SIDs
        LDA #$00                ; 
        STA SID+$05             ; voice 1 Attach/Decay 
        STA SID+$0C             ; voice 2 Attach/Decay 
        STA SID+$13             ; voice 3 Attach/Decay 
        STA SID+$15             ; filter  lo 
        LDA #$F0                ;
        STA SID+$06             ; voice 1 Systain/Release 
        STA SID+$0D             ; voice 2 Systain/Release 
        STA SID+$14             ; voice 3 Systain/Release 
        LDA #$01                ;
        STA SID+$04             ; voice 1 ctrl 
        STA SID+$0B             ; voice 2 ctrl        
        STA SID+$12             ; voice 3 ctrl 
        LDA #$10                ;
        STA SID+$16             ; filter  hi 
        LDA #$F7                ;
        STA SID+$17             ; filter  voices+reso 

;         ; blank screen, don't really have to though
;         LDA $D011      ; VICII control register 1
;         AND #$EF
;         STA $D011 

        ; set up the various ''pointers'
        LDA #<NMI_HANDLER       ; point to our first NMI handler 
        STA $FFFA               ; NMI handler address low byte
        LDA #>NMI_HANDLER       ; 
        STA $FFFB               ; NMI handler address hi byte

        LDA #<DATASTART         ; Set up self modifying pointer to sample data
        STA loadnew+1           ; to current low byte
        LDA #>DATASTART         ; Set up self modifying pointer to sample data
        STA loadnew+2           ; to current high byte

        lda DATASTART           ; get first sample byte, store to 
        sta n0L                 ; low nibble zero page spot
        INC loadnew+1           ; increment self-mod pointer LSB

        LDA #<DATASTART         ; Set up self modifying pointer to sample data
        STA peeknext+1          ; to next low byte
        INC peeknext+1          ; our inital peeknext will 2 bytes in,
        INC peeknext+1          ; which is 1 byte ahead of loadnew+1
        LDA #>DATASTART         ; Set up self modifying pointer to sample data
        STA peeknext+2          ; to next high byte
        
        ; setup CIA #2, do last as it starts interrupts!
        LDA #<freq              ; interrupt freq
        STA $DD04               ; TA LO
        LDA #>freq              ;
        STA $DD05               ; TA HI

        LDA #$81                ; ICR set to TMR A underflow
        STA $DD0D               ; ICR CIA #2
        LDA #$11                ;
        STA $DD0E               ; CRA interrupt enable

        LDA #$FE                ; 2- reset counter/index
        STA ctr                 ; 3- (5)

        LDA #$00                ;
        STA done                ; reset player done flag

pause
        LDA done                ; player sets'done' flag when finished, pause
        BEQ pause               ; until then for clean return to BASIC

        PLA                     ; Let's get our saved
        TAX                     ; X register and
        PLA                     ; A register back
        CLI                     ; enable maskable interrutps again
        RTS                     ; and return

;-------------------------------------------------------------------------------
; NMI Handler
;
; We have one main NMI ISR entry point in this interpolating player version
; but we have four different paths after the n0L nibble is played, ISR0-ISR3.
; Each ISR_# handles loading/masking/shifting the sample data so the next
; nibble to play is always in n0L
; 
; We are also using two different self-modyfying 'pointers'. 
; loadnew+1, loadnew+2 is the 'pointer' to the current sample byte called, 'A'
; peeknext+1, peeknext+2 is the 'pointer' to peek at the next sample byte, 'B'
; All sample data is page aligned so we only need to check for end of data
; when crossing a page boundry and we only do so for "loadnew"
;
; GENERAL NMI HANDLER -
; play n0L nibble, branch to correct ISR_# to process correct nibbles
; total cycles 22+9 = 31 thru (ISR0)
; total cycles 22+10 = 32 branch1 (ISR1)
; total cycles 22+8 = 30 branch2 (ISR2 or ISR3), 
NMI_HANDLER
        PHA                     ; 3- will restore when returning
        LDA n0L                 ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (22) clear NMI
        
        LDA #$01                ; 2-
        BIT ctr                 ; 3- ***explain BIT operation
        BPL ISR_2               ; 2-3 (8-branch2)
        BNE ISR_1               ; 2-3 (9-thru, 10-branch1)


; ISR #0 - calc mid point of hiA-loA save to n0L (queue it), move hiA to n0M
; total cycles 31+29+9 = 69 31+34+9 = 74
ISR_0
        INC ctr                 ; 5- inc counter so next ISR used next pass
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


; ISR #1, move n0M (hiA) to n0L (queue it)
; total cycles 32+11+9 = 52
ISR_1
        INC ctr                 ; 5- inc counter so next ISR used next pass
        lda n0M                 ; 3- move mid->low
        sta n0L                 ; 3- (11)move mid->low

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9) 


; ISR #2, peek at sample B and calc mid point of loB-hiA save to n0L
; total cycles = 30+3 = 33, branch to ISR_3
; total cycles = 30+7+7+7+9 = 60, peeknext path
; total cycles = 30+7+7+8+3+9 = 64, nextPeekPage path
ISR_2
        BNE ISR_3               ; 2-3 branch to ISR_3 if we should
        INC ctr                 ; 5- (3-7)inc counter so next ISR used next pass

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
        INC peeknext+2          ; 3- (3) increment self-mod pointer MSB

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)


; ISR #3, load sample B, inc loadnew pointer, reset counter/indexer
; total cycles 33+5+13+16 = 67, incptr path
; total cycles 33+5+14+21 = 73, nextPage path
ISR_3    
        LDA #$FE                ; 2- reset out routint counter/index
        STA ctr                 ; 3- (5)

loadnew
        LDA $FFFF               ; 3 -self-mod pointer to sample
        sta n0L                 ; 3- save low nibble

incptr
        INC loadnew+1           ; 5 - increment self-mod pointer LSB
        BEQ @nextPage           ; 2-3- (13thru-14branch) did we cross a page?

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (16thru-8branch)

@nextPage
        LDA loadnew+2           ; 3- increment self-mod pointer MSB
        ADC #$01                ; 2- carry is clear from flag test
        CMP #>DATASTOP          ; 2- are we done?
        BEQ @stop               ; 2-3- yes, then stop
        STA loadnew+2           ; 3- no, save new MSB

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (21thru-)

@stop
        LDA #$00                ; 2- turn off NMI
        STA $DD0E               ; 4- timer A stop-CRA, CIA #1 DC0E
        LDA #$4F                ; 2- disable all CIA-2 NMIs 
        STA $DD0D               ; 4- ICR - interrupt control / status
        LDA $DD0D               ; 4- (16) sta/lda to ack any pending int

        LDA #$37                ; 2- reset kernal banking
        STA $01                 ; 3- (5)
        
        INC done                ; set player done flag
        
        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- faster than jumps/branches








        