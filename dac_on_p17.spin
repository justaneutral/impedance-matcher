{{ dac_on_p17
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

PUB get(DacValue): sample | DacP17Value, DacP17Step, DacP17MaxStep, DacP17ValueMax, i, j 
  DacP17Value := DacValue
  DacP17Step := 1
  DacP17MaxStep := 100
  DacP17ValueMax := 2000
  repeat j from 0 to 100
      i := 2*ina[19]-1
      DacP17Value += i
      if i>0 and DacP17Step > 0
        DacP17Step := DacP17Step*2
        if DacP17Step > DacP17MaxStep
          DacP17Step := DacP17MaxStep 
      else
        if i<0 and DacP17Step<0
          DacP17Step := DacP17Step*2
          if DacP17Step < -DacP17MaxStep
            DacP17Step := -DacP17MaxStep 
        else
          DacP17Step := i
      DacP17Value += DacP17Step
      if DacP17Value > DacP17ValueMax
        DacP17Value := DacP17ValueMax
      else
        if DacP17Value < 0
          DacP17Value := 0
      set(DacP17Value)
      waitcnt(2000+cnt)
  sample := DacP17Value

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

diraval long |< 17
ctraval long %00110 << 26 + 0<<9 + 17         'NCO/PWM APIN=17
period  long 2000                            '800kHz period (_clkfreq / period)                      
time    res 1
value   res 1