{{ dac_on_p16
                     10kΩ
                APIN ─┳── Out
                        │
                       .1µF
                        
Delta modulation has no fundamental freq but has quantization noise  
}}
VAR
  long parameter, cog, dacval

PUB set(val)
  parameter := $20C49B * val '$1_0000_0000 / period
  result := val

PUB start | x
  cog := cognew(@entry, @parameter)
  dacval := 999
  result := cog
  
PUB measure(averaging): sval | index, sum
  sum := get(dacval)
  repeat index from 0 to averaging
    dacval := get(dacval)
    sum += dacval
  sval := sum

PUB get(DacValue): sample | DacP16Value, DacP16Step, DacP16MaxStep, DacP16ValueMax, i, j 
  DacP16Value := DacValue
  DacP16Step := 1
  DacP16MaxStep := 100
  DacP16ValueMax := 2000
  repeat j from 0 to 100
      i := 2*ina[18]-1
      DacP16Value += i
      if i>0 and DacP16Step > 0
        DacP16Step := DacP16Step*2
        if DacP16Step > DacP16MaxStep
          DacP16Step := DacP16MaxStep 
      else
        if i<0 and DacP16Step<0
          DacP16Step := DacP16Step*2
          if DacP16Step < -DacP16MaxStep
            DacP16Step := -DacP16MaxStep 
        else
          DacP16Step := i
      DacP16Value += DacP16Step
      if DacP16Value > DacP16ValueMax
        DacP16Value := DacP16ValueMax
      else
        if DacP16Value < 0
          DacP16Value := 0
      set(DacP16Value)
      waitcnt(2000+cnt)
  sample := DacP16Value

PUB stop
  cogstop(cog)
  
DAT
        org

entry   mov dira, diraval
        mov ctra, ctraval

        mov time, cnt
        add time, period

:loop   rdlong value, par
        waitcnt time, period
        mov  frqa, value                        
        jmp #:loop

diraval long |< 16
ctraval long %00110 << 26 + 0<<9 + 16         'NCO/PWM APIN=16
period  long 2000                            '800kHz period (_clkfreq / period)                      
time    res 1
value   res 1