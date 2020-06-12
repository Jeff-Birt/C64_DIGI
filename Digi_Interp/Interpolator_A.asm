;///////////////////////////////////////////////////////////////////////////////
; A try at an interpolating DIGI Player

n0L = $19
n0M = $20
n0H = $21

freq     = $80           ; CIA NMI timer delay, 8kHz

;===============================================================================
; BASIC Loader

*=$0801 ; 10 SYS (4096)

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
        LDA #<NMI_HANDLER0      ; point to our first NMI handler 
        STA $FFFA               ; NMI handler address low byte
        LDA #>NMI_HANDLER0      ; 
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
        LDA #<freq              ; 
        STA $DD04               ; TA LO interrupt freq
        LDA #>freq              ;
        STA $DD05               ; TA HI interrupt freq

        LDA #$81                ; ICR set to TMR A underflow
        STA $DD0D               ; ICR CIA #2
        LDA #$11                ;
        STA $DD0E               ; CRA interrupt enable

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


*= $1100

;-------------------------------------------------------------------------------
; NMI Handler
;
; We have four different NMI handlers, after NMI_HANDLER0 is done it changes
; the NMI vector in HI RAM to point to NMI_HANDLER1, etc. This lets us call the
; required code for each stage of interpolation without needing any comparisons
; which woudl take more clock cycles.
;
; We are also using two different self-modyfying 'pointers'. 
; loadnew+1, loadnew+2 is the 'pointer' to the current sample byte called, 'A'
; peeknext+1, peeknext+2 is the 'pointer' to peek at the next sample byte, 'B'
; All sample data is page aligned so we only need to check for end of data
; when crossing a page boundry and we onoly do so for "loadnew"
;
; We play current loA nibble, calc mid point of hiA-loA save to n0L
; and move the hiA which was still in n0L to n0M
; total cycles: 22+29+7+9 = 67
NMI_HANDLER0  
        PHA                     ; 3- save A as we are going to use it
        LDA n0L                 ; 3- load sample byte/nibble
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (22) clear NMI       

        lda n0L                 ; 3- n0L still has data in upper nibble
        lsr                     ; 2- shift to lower nibble position
        lsr                     ; 2- doing this here to even out
        lsr                     ; 2- cycles between ISRs
        lsr                     ; 2- 
        sta n0M                 ; 3- save hiA to mid nibble address
        lda n0L                 ; 3- get origianl byte again
        and #$0F                ; 2- save only lower nibble
        clc                     ; 2- clear carry before add
        adc n0M                 ; 3- add loA to hiA and /2 
        lsr                     ; 2- to get an average
        sta n0L                 ; 3- (29) is played on next ISR as lo 

        LDA #<NMI_HANDLER1      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (7)

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)


; We play current mid of hiA+loA (in n0L), then move mid(hiA) to n0L position
; total cycles 22+6+7+9 = 44
NMI_HANDLER1
        PHA                     ; 3- save A as we are going to use it
        LDA n0L                 ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (22) clear NMI

        lda n0M                 ; 3- move mid(hiA) to n0L address
        sta n0L                 ; 3- (6)

        LDA #<NMI_HANDLER2      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (7)

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9) 


; We play hiA, calc mid point of loNext-hi save to lo, we do not need to check
; if we are at the end of the sample here, that is done in NMI_HANDLER3
; total cycles 22+7+7+7+9 = 52 or 22+7+8+10+9 = 56
NMI_HANDLER2
        PHA                     ; 3- save A as we are going to use it
        LDA n0L                 ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (22) clear NMI

peeknext 
        lda $FFFF               ; 3- peek next sample byte via self mod. pointer
        and #$0F                ; 2- keep only the low nibble of next sample               
        clc                     ; 2- clear carry before adding next low nibble 
        adc n0L                 ; 3- loB to previuos hi nibble hiA
        lsr                     ; 2- /2 to get an average midpoint value
        sta n0L                 ; 3- (7) save it to play next as n0L

        INC peeknext+1          ; 5 - increment self-mod pointer LSB
        BEQ nextPeekPage        ; 2-3 (7-8) did we cross a page?

        LDA #<NMI_HANDLER3      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (7) 
        
        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)

nextPeekPage
        INC peeknext+2          ; 3- increment self-mod pointer MSB
        LDA #<NMI_HANDLER3      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (10)

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)


; We play midpoint of hiA-loB, load next byte, B, save to n0L
; total cycles 22+6+7+7+9 = 51 or 22+6+8+12+7+9 = 64
NMI_HANDLER3
        PHA                     ; 3- save A as we are going to use it
        LDA n0L                 ; 3- load sample byte
        ORA #$10                ; 2- make sure we don't kill filter settings
        AND #$1F                ; 2- git rid of any dangling high bits
        STA SID+$18             ; 4- save to SID volume regsiter
        STA $D020               ; 4- change border color, something to look at
        LDA $DD0D               ; 4- (22) clear NMI

loadnew
        LDA $FFFF               ; 3 -self-mod pointer to sample
        STA n0L                 ; 3-(6) save byte to low nibble, m0L, address

        INC loadnew+1           ; 5 - increment self-mod pointer LSB
        BEQ @nextPage           ; 2-3 (7-8) did we cross a page boundry?

        LDA #<NMI_HANDLER0      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (7)

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)

@nextPage
        ; this is only executed every 512 samples
        LDA loadnew+2           ; 3- increment self-mod pointer MSB
        ADC #$01                ; 2- carry is clear from flag test
        CMP #>DATASTOP          ; 2- are we done?
        BEQ @stop               ; 2-3- yes, then stop
        STA loadnew+2           ; 3-(12) no, save new MSB

        LDA #<NMI_HANDLER0      ; 3- set NMI handler address low byte
        STA $FFFA               ; 4- (7)

        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- (9)


@stop
        LDA #$08                ; 2- turn off NMI
        STA $DD0E               ; 4- timer A stop-CRA, CIA #1 DC0E
        LDA #$4F                ; 2- disable all CIA-2 NMIs 
        STA $DD0D               ; 4- ICR - interrupt control / status
        LDA $DD0D               ; 4- (16) sta/lda to ack any pending int

        LDA #$37                ; 2- reset kernal banking
        STA $01                 ; 3- (5)
        
        INC done                ; set player done flag
        
        PLA                     ; 3- local exit code is smaller and
        RTI                     ; 6- faster than jumps/branches








        