{{ comparator_on_p17f_p19s.spin
                     10kΩ
                APIN ─┳── Out
                        │
                       .1µF
                        
Delta modulation has no fundamental freq but has quantization noise  
}}
VAR
  long parameter, cog

PUB set(val)
  parameter := $20C49B * val '$1_0000_0000 / period
  result := val

PUB get(InitValue): sample | DacValue, DacStep, DacMaxStep, DacValueMax, i, j 
  DacValue := InitValue
  DacStep := 1
  DacMaxStep := 100
  DacValueMax := 2000
  repeat j from 0 to 100
      i := 2*ina[19]-1
      DacValue += i
      if i>0 and DacStep > 0
        DacStep := DacStep*2
        if DacStep > DacMaxStep
          DacStep := DacMaxStep 
      else
        if i<0 and DacStep<0
          DacStep := DacStep*2
          if DacStep < -DacMaxStep
            DacStep := -DacMaxStep 
        else
          DacStep := i
      DacValue += DacStep
      if DacValue > DacValueMax
        DacValue := DacValueMax
      else
        if DacValue < 0
          DacValue := 0
      set(DacValue)
      waitcnt(2000+cnt)
  sample := DacValue


PUB start | x
  cog := cognew(@entry, @parameter)
  result := cog
  
{  repeat
    repeat x from 0 to period
      parameter := $20C49B * x '$1_0000_0000 / period
      waitcnt(1000 +cnt)
}

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