NMI_Handler:
  PHA

  ; load sample into SID
  LDA sample
  ORA #$10
  AND #$1F
  STA SID+$18
  STA $D020  ; border colour
  LDA $DD0D  ; clear NMI

  ; alternate high/low nybble
  ASL flag
  BCC @lower
  INC flag

@upper:
  LDA sample
  LSR A
  LSR A
  LSR A
  LSR A
  STA sample

  ; local exit code is now both smaller and faster than jumping to it
  PLA
  RTI

@lower:
  LDA $FFFF  ; self-mod pointer to sample - overwrite this operand during init
  STA sample
  INC @lower+1
  BEQ @nextPage

  ; local exit code is now both smaller and faster than jumping to it
  PLA
  RTI

@nextPage:
  ; this is only executed every 512 samples
  LDA @lower+2
  ADC #1     ; carry is clear from flag test
  CMP #stopPage
  BEQ @stop
  STA @lower+2

  ; local exit code is now both smaller and faster than jumping to it
  PLA
  RTI

@stop:
  ; switch off the timers
  LDA #0
  STA $DD0E
  LDA #$4F
  STA $DD0D
  LDA $DD0D

  ; restore banking
  LDA #$37
  STA $01
  PLA
  RTI