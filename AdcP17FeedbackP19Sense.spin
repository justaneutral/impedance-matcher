{{ AdcP17FeedbackP19Sense.spin

               External signal──  Comparator (+) input
               
                     10kΩ                              Comparator output ── In P19 
            APIN P17 ─┳── Out   Comparator (-) input
                        │
                       .1µF
                        
Delta modulation has no fundamental freq but has quantization noise  
}}
VAR
  long parameter, cog

PUB get : val
  'val := parameter / $20C49B  '$1_0000_0000 / period
  val := parameter  '$1_0000_0000 / period
PUB start | x
  cog := cognew(@entry, @parameter)
  result := cog
  
{  repeat
    repeat x from 0 to period
      parameter :=  * x '$1_0000_0000 / period
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

'update return value
:loop   wrlong value, par
':loop   wrlong period, par
        waitcnt time, period
        mov  frqa, value
        subs value, #1
        test ina,maskP19 wz 'check pin p19 - comparator output
        if_nz adds value, #2
        maxs value, maxval
        mins value, minval
        jmp #:loop

diraval long |< 17
ctraval long %00110 << 26 + 0<<9 + 17         'NCO/PWM APIN=17
period  long 2000                            '800kHz period (_clkfreq / period)
maxval  long $20C49B*1000
minval  long $20C49B*(-1000)
maskP19 long |<19
value   long 0 
time    res 1