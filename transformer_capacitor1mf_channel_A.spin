'PWM version of NCO/PWM counter mode for current source
' for Udd = 20V, max current I_max = 1.3 A at angle = 4800 for R_load = 0.47 + j0 Ohm
' for Udd = 20V, max short cirquit at load current I_max_short =  A at angle = 
CON
  maxstp   =    256
  normalstep = 8
  minstp   =    1
VAR long cog,x,angle,stp,scale

PUB increment : a
  a := set(angle+stp*scale)

PUB decrement : a
  a := set(angle-stp*scale)

PUB offset(s) : a
  a := set(angle+s)

PUB stpincrement : a
  a := setstp(stp*2)

PUB stpdecrement : a
  a := setstp(stp/2)

PUB setstepscale(s)
  scale := s

PUB getstepscale : s
  s := scale  

PUB get : x1
  x1 := angle

PUB getstp : s1
  s1 := stp

PUB setstp(newstp)
  if newstp>maxstp
    stp := maxstp
  else
    if newstp<minstp
      stp := minstp
    else
      stp := newstp

PUB set(newangle)
  angle := newangle
  if(newangle>4600)
    angle :=4600
  if(newangle<0)
    angle :=0
  x:=(period/2)<<16 + period/100 + (period*angle/10000)
  result := angle

PUB start : cogcode
  setstepscale(1)
  stp := normalstep
  angle := 0
  cog := cognew(@entry, @x)
  cogcode := cog

PUB stop
  cogstop(cog)
  
DAT
'assembly cog which updates the PWM cycle on APIN
'for audio PWM, fundamental freq which must be out of auditory range (period < 50µS)
        org
entry   mov dira, diraval              'define L298 control signals as outputs
        mov outa, outvals              'set L298 control signal values
        mov ctra, ctravalA             'establish counter A mode and APIN
        mov frqa, #%1                   'set counter to increment 1 each cycle
        mov ctrb, ctravalB             'establish counter B mode and APIN
        mov frqb, #%1                   'set counter to increment 1 each cycle
        mov time, cnt                  'record current time
        add time, period               'establish next period
:loop   rdlong value1, par
        'mov value1, address              'get an up to date pulse width
        mov value2, value1
        shr value1, #16
        and value2, mask
        mov period1, period
        sub period1, value2
        waitcnt time, period1           'wait until next period
        neg phsa, value1                'back up phsa so that it
        waitcnt time, value2           'wait until next period
        neg phsb, value1                'back up phsa so that it
        jmp #:loop                     'loop for next cycle
diraval long |< 25 +|<27 + |<26 + |< 24 + |<23 + |<22    'L298 control signals: EA,In1,In2,EB,In3,In4
'p25-EA
'p27-In1
'p26-In2
'p24-EB
'p23-In3
'p22-In4
outvals long |<25           'EA=1, EB=0
                            'APIN=In2(26)/In4(22) BPIN=In1(27)/In3(23)
ctravalA long %00100<<26 + 27'23 ' + 27<<9       'NCO/PWM APIN=0
ctravalB long %00100<<26 + 26'22 ' + 23<<9 'failed p23-In3's out      'NCO/PWM APIN=0

'period  long 25600 'failed at 80                       '800kHz (1.25µS period) (_clkfreq / period)                      
 period  long 6400 '6400
'period  long 3200
mask    long %1111_1111_1111_1111
time    res 1
period1 res 1
value1   res 1
value2  res 1
'address res 1