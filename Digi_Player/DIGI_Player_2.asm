;===============================================================================
; DIGI_Player_2
; DIGI Player using a minimal NMI_HANDLER and sample decoding 
; done outside the handler
;===============================================================================

;SID     = $D400         ; base address of SID chip
;start   = DATASTART     ; start of sample
;end     = DATASTOP      ; end of sample
; freq    = $80           ; CIA NMI timer delay
;ptr     = $FD           ; pointer to current byte of sample

*= $1000

;*******************************************************************************
; Initialize DIGI_Player
;*******************************************************************************

        LDA #$35                ; switch out roms while sample playing
        STA $01                 ; 6510 banking register
        LDA #$00                ; disable interrupts
        STA $DD0D               ; ICR CIA #2
        LDA $DD0D               ; read acks any pending interrupt
        SEI                     ; disables maskable interrupts

        ; initialize SID registers
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
;         LDA $D011      ; VICII control register 1
;         AND #$EF
;         STA $D011 

        ; point NMI vector to our player routine
        LDA #<NMI_HANDLER       ; set NMI handler address low byte
        STA $FFFA               ;
        LDA #>NMI_HANDLER       ; set NMI handler address low byte
        STA $FFFB               ;

        ; set pointer to beginning address of sample data
        LDA #<DATASTART         ; low byte
        STA ptr                 ;
        LDA #>DATASTART         ; high byte
        STA ptr+1               ;
        
; *** start of decoding ***
decode_start
        ; *** how to preload one buffers worth of data before playing?
        ; load a sample and determine if it is RLE, byte = $00 is RLE marker
        LDA #$01                ; 4- flag should start at 1
        STA flag                ; 4- to denote a non RLE byte
        LDY #$00                ; 4- set offset to first byte
        LDA (ptr),y;            ; 5- load in first sample byte
        STA sample              ; 4- save just in case it is not RLE
        BNE notRLE              ; 3- (24) skip ahead if not RLE marker of $00

        ; here we decode an RLE pair
        INC ptr                 ; 5- inc the sample pointer
        BNE @skip               ; 3- if we did not roll over low byte skip ahead
        INC ptr+1               ; 5- (13)inc the high byte
@skip     
        LDA (ptr),y             ; 5- load RLE byte in
        TAX                     ; 2- save a copy of RLE byte
        LSR A                   ; 2- shift count down to low nibble
        LSR A                   ; 2- encoded count is actual - 1
        LSR A                   ; 2- additional copy of value in high nibble
        LSR A                   ; 2- gives us proper # for playback
        STA flag                ; 4- save count
        TXA                     ; 2- get back our original byte
        AND #$0F                ; 2- mask off high nibble
        STA sample              ; 4- save our low nibble only
        CLC                     ; 2- make sure carry bit clear
        ROL                     ; 2- shift low nibble up to high nibble
        ROL                     ; 2-
        ROL                     ; 2-
        ROL                     ; 2- now we have copy of low nibble in high nibble
        ORA sample              ; 4- OR to combine both nibbles
        STA sample              ; 4- (45)store back to sample byte address  

notRLE
        OutBufWrite             ; 24- save A in OutBuf
        BNE keep_decoding       ; 3- if X!=0 OutBuf not full, keep decoding
        LDX irq_on              ; 4- if full and IRQ not running start IRQ
        BNE notRLE              ; 3- if IRQ is running loop until buffer not full
start_IRQ
        ; setup CIA #2, do last as it starts interrupts!
        LDX #<freq              ; interrupt freq
        STX $DD04               ; TA LO
        LDX #>freq              ;
        STX $DD05               ; TA HI

        LDX #$81                ; ICR set to TMR A underflow
        STX $DD0D               ; ICR CIA #2
        LDX #$11                ;
        STX $DD0E               ; CIA interrupt enable
        INC irq_on              ; set flag to IRQ running
        BNE notRLE              ; Z !=0 after INC so we can use BNE
        
keep_decoding
        INC ptr                 ; 5- inc the sample pointer low byte
        BNE checkend            ; 3- if we did not roll over low byte skip ahead
        INC ptr+1               ; 5- (13) inc the high byte

checkend 
        LDA ptr                 ; 4- if not at end of sample exit/return from NMI 
        CMP #<DATASTOP          ; 4- low byte
        BNE loop                ; 3-
        LDA ptr+1               ; 4- high byte
        CMP #>DATASTOP          ; 4-
        BNE loop                ; 3- (22)
        RTS                     ; done decoding
loop
        jmp decode_start        ; 6- not done decoding yet (157 for oen byte)




;*******************************************************************************
; NMI handler routine, plays one 4bit sample per pass
; let's do the bare minimum in the interrupt handler as it fires at 8kHz so
; any ocde here is run 8,000 times/second and uses a LOT of processor cycles
; NMI will run unitl OutBuf is empty then NMI turned off
;*******************************************************************************

NMI_HANDLER        
         ; save state, could save to ZP save 1 cycle on PLA, 2 on TXA
         PHA                    ; 3- will restore when returning
         TXA                    ; 2-
         PHA                    ; 2-

         ; play 4-bit sample, should be low nibble only and fully processed
         OutBufRead             ; (20) value returned in A
         BEQ BUF_EMPTY          ; 3- if X==0 then buffer empty, skip
         STA SID+$18            ; 4- save to SID volume regsiter
         STA $D020              ; 4- change border color for something to look at
         LDA $DD0D              ; 4- clear NMI
                                ; 
         PLA                    ; 4- restore state
         TAX                    ; 2-
         PLA                    ; 4-
         RTI                    ; 6- return from this pass of NMI
                                ; 56 total clock cycles

BUF_EMPTY                       ; skip to here if buffer is empty
         LDA #$00               ; turn off NMI
         STA $DD0E              ; timer A stop-CRA, CIA #1 DC0E
         LDA #$4F               ; disable all CIA-2 NMIs 
         STA $DD0D              ; ICR - interrupt control / status
         LDA $DD0D              ; sta/lda to ack any pending int

         LDA #$37               ; reset kernal banking
         STA $01                ;

         PLA                    ; 4- restore state
         TAX                    ; 2-
         PLA                    ; 4-
         RTI                    ; 6- return from this pass of NMI
                                ; 56 total clock cycles

         ; Sample's lower nybble holds the 4-bit sample to played on the
         ; next NMI. The upper nybble holds the next nybble to be
         ; played on "odd" NMIs, and is undefined on "even" NMIs.
sample   
        BYTE $00


         ; flag simply toggles between 0 and 1 - used to decide whether
         ; to play upper or lower nybble
flag     
        BYTE $00

irq_on  
        BYTE $00    

