'matcher top entry is here

CON
  togglecntrmax = 4
  version = 20140628
  avercnt = 1
  dempfer = 64
  scaler = 10
  reflectionthreshold = -3000
  magnetizationdelay = 12000000
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  pst                        : "Parallax Serial Terminal"
  CurrentSourceShunt         : "transformer_capacitor1mf_channel_A"
  CurrentSourceBallast       : "transformer_capacitor1mf_channel_B"
  dac_p16                    :  "dac_on_p16" 'used by comparator on P19
  dac_p17                    :  "dac_on_p17" 'used by comparator on P19
  'adc0                       : "AdcP17FeedbackP19Sense"
       

VAR  
  long togglemeasurements, newcnt, symbol, prevreflected  

PUB run
  repeat
    execute

PRI bettermatch(curr,curp,bestr,bestp) : d
  d := false
  if bestr > 0
    if bestr > curr
      d := true
  else
    if bestp < curp
        d := true
  if bestr == 0
    if curr > 0
      d := false
     
PRI calculateswr(p,r) : s
  s:=p-r

PRI getpower : p
  p := dac_p16.measure(avercnt)

PRI getreflected : r
  r := dac_p17.measure(avercnt)

PRI minimum(a,b) : s
  s := a#>b

PRI maximum(a,b) : s
  s := a<#b

PRI slowfind | curp, curr, curb,curs,bestp,bestr,bests,bestb,swr
  pst.clear
  pst.position(0,0)
  pst.str(string("Setting shunt inductor to medium impedance"))
  pst.newline
  curs := 2000
  bests := curs
  CurrentSourceShunt.set(curs)
  pst.str(string("Setting ballast inductor to maximum impedance"))
  pst.newline
  CurrentSourceBallast.set(0)
  pst.str(string("Bringing ballast to resonance"))
  pst.newline
  curb := 0
  CurrentSourceBallast.set(curb)
  pst.str(string("ballast current "))
  pst.dec(CurrentSourceBallast.get)
  bestp := getpower
  bestr := getreflected
  pst.str(string("  best power "))
  pst.dec(bestp)
  pst.str(string("  best reflected "))
  pst.dec(bestr)
  pst.newline
  repeat curb from CurrentSourceBallast.getstp to 4600 step CurrentSourceBallast.getstp
    CurrentSourceBallast.set(curb)
    waitcnt(cnt + magnetizationdelay)
    pst.str(string("ballast current "))
    pst.dec(CurrentSourceBallast.get)
    curp := getpower
    curr := getreflected
    pst.str(string("  power "))
    pst.dec(curp)
    pst.str(string("  reflected "))
    pst.dec(curr)
    swr := calculateswr(curp,curr)
    pst.str(string("  swr "))
    pst.dec(swr)
    if bettermatch(curr,curp,bestr,bestp)
      bestp := curp
      bestr := curr
      bestb := curb
      pst.str(string(" *"))
    pst.newline
  CurrentSourceBallast.set(bestb)
  pst.str(string("Adjusting shunt coil current"))
  pst.newline
  repeat curs from CurrentSourceShunt.getstp to 4600 step CurrentSourceShunt.getstp
    CurrentSourceShunt.set(curs)
    waitcnt(cnt + magnetizationdelay)
    pst.str(string("shunt current "))
    pst.dec(CurrentSourceShunt.get)
    curp := getpower
    curr := getreflected
    pst.str(string("  power "))
    pst.dec(curp)
    pst.str(string("  reflected "))
    pst.dec(curr)
    if bettermatch(curr,curp,bestr,bestp)
      bestp := curp
      bestr := curr
      bests := curs
      pst.str(string(" *"))
    pst.newline
  CurrentSourceShunt.set(bests)
  pst.str(string("Resonance found @ ballast current "))
  pst.dec(bestb)
  pst.str(string("  Shunt current "))
  pst.dec(bests)  
  pst.str(string("  Direct power "))
  pst.dec(bestp)
  pst.str(string("  Reflected "))
  pst.dec(bestr)
  pst.newline
  pst.str(string("Hit any key"))
  pst.newline
  repeat while pst.rxcount == 0
  
  

PRI ballastgradient | i,j,n,p,dn,dp,nswr,pswr,balloffset[2]
  pst.position(0,0)
  CurrentSourceBallast.decrement                         '--------
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("b- Direct/Reflected/SWR: "))
  pst.dec(dn:=getpower)
  pst.str(string(", "))
  pst.dec(n:=getreflected)
  pst.str(string(", "))
  pst.dec(nswr:=calculateswr(dn,n))
  pst.str(string("  Sunt/Ballast: "))
  pst.dec(CurrentSourceShunt.get)
  pst.str(string(", "))
  pst.dec(CurrentSourceBallast.get)
  pst.clearend
  pst.NewLine
  CurrentSourceBallast.increment                         '++++++++
  CurrentSourceBallast.increment                         '++++++++
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("b+ Direct/Reflected/SWR: "))
  pst.dec(dp:=getpower)
  pst.str(string(", "))
  pst.dec(p:=getreflected)
  pst.str(string(", "))
  pst.dec(pswr:=calculateswr(dp,p))
  pst.str(string("  Sunt/Ballast: "))
  pst.dec(CurrentSourceShunt.get)
  pst.str(string(", "))
  pst.dec(CurrentSourceBallast.get)
  CurrentSourceBallast.decrement                         '--------
  pst.clearend
  pst.NewLine
  pst.str(string("db Direct/Reflected/SWR: "))
  pst.dec(dp-dn)
  pst.str(string(", "))
  pst.dec(p-n)
  pst.str(string(", "))
  pst.dec(pswr-nswr)
  pst.str(string("  Ballast offset: "))

  if pswr =< -6000 and nswr =< -6000  'dead zone
      pst.str(string("  Dead zone, go forward"))
      CurrentSourceBallast.setstepscale(scaler)
      CurrentSourceBallast.set(((CurrentSourceBallast.get+CurrentSourceBallast.getstp*CurrentSourceBallast.getstepscale)#>0)//4601)    
  else
    if reflectionthreshold => maximum(pswr,nswr) 'high reflection 
      pst.str(string("  High reflection zone, set wide step "))
      CurrentSourceBallast.setstepscale(scaler)
    else
      CurrentSourceBallast.setstepscale(1)  
      pst.str(string("  Low reflection zone, set narrow step "))
    CurrentSourceBallast.offset(((nswr-pswr)<#(-CurrentSourceBallast.getstp*CurrentSourceBallast.getstepscale))#>CurrentSourceBallast.getstp*CurrentSourceBallast.getstepscale)  
    if pswr > nswr
      pst.char("+")
    else
      if pswr < nswr
        pst.char("-")
      else
        pst.char("*")
  pst.clearend
  
  

PRI shuntgradient | i,j,n,p,dn,dp,nswr,pswr,shuntoffset[2]
  pst.position(0,8)
  CurrentSourceShunt.setstepscale(((getreflected/(getpower#>1))#>1)<#scaler)
  CurrentSourceShunt.decrement
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("s- Direct/Reflected/SWR: "))
  pst.dec(dn:=getpower)
  pst.str(string(", "))
  pst.dec(n:=getreflected)
  pst.str(string(", "))
  pst.dec(nswr:=calculateswr(dn,n))
  pst.str(string("  Sunt/Ballast: "))
  pst.dec(CurrentSourceShunt.get)
  pst.str(string(", "))
  pst.dec(CurrentSourceBallast.get)
  pst.clearend
  pst.NewLine
  CurrentSourceShunt.increment
  CurrentSourceShunt.increment  
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("s+ Direct/Reflected/SWR: "))
  pst.dec(dp:=getpower)
  pst.str(string(", "))
  pst.dec(p:=getreflected)
  pst.str(string(", "))
  pst.dec(pswr:=calculateswr(dp,p))
  pst.str(string("  Sunt/Ballast: "))
  pst.dec(CurrentSourceShunt.get)
  pst.str(string(", "))
  pst.dec(CurrentSourceBallast.get)
  CurrentSourceShunt.decrement
  pst.clearend
  pst.NewLine
  pst.str(string("db Direct/Reflected/SWR: "))
  pst.dec(dp-dn)
  pst.str(string(", "))
  pst.dec(p-n)
  pst.str(string(", "))
  pst.dec(pswr-nswr)
  pst.str(string("  Shunt offset: "))
  if pswr =< -6000 and nswr =< -6000  'dead zone
    pst.str(string("  Dead zone, go forward"))
    CurrentSourceShunt.setstepscale(scaler)
    CurrentSourceShunt.set(((CurrentSourceShunt.get+CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale)#>0)//4601)    
  else
    if reflectionthreshold=> maximum(pswr,nswr) 'high reflection 
      pst.str(string("  High reflection zone, set wide step "))
      CurrentSourceShunt.setstepscale(scaler)
    else
      CurrentSourceShunt.setstepscale(1)  
      pst.str(string("  Low reflection zone, set narrow step "))
    CurrentSourceShunt.offset(((nswr-pswr)<#(-CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale))#>CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale)
    if pswr > nswr
      pst.char("+")
      'CurrentSourceShunt.increment
    else
      if pswr < nswr
        pst.char("-")
        'CurrentSourceShunt.decrement
      else
        pst.char("*")
  pst.clearend
   


{  'shuntoffset[0]:=(scaler*(p+n+dempfer)/(dp+dn+dempfer))#>1
  shuntoffset[0]:=((minimum(p,n)-maximum(dp,dn))#>1)<#scaler
  shuntoffset[1]:=n-p  ' (pswr-nswr) dp-p-dn+n = (n-p)-(dn-dp)
  if shuntoffset==0
    shuntoffset[1]:=((dp-dn)#>-1)#>1
  'shuntoffset[0]:=(shuntoffset[0]#>(-CurrentSourceShunt.getstp))<#CurrentSourceShunt.getstp
  'shuntoffset[1]:=(shuntoffset[1]+((shuntoffset[0]-shuntoffset[1]>>4)>>4)#>(-CurrentSourceShunt.getstp))<#CurrentSourceShunt.getstp
  pst.dec(shuntoffset[0])
  pst.char("*")
  pst.dec(shuntoffset[1])
  pst.char("=")
  pst.dec(j:=(((shuntoffset[0]*shuntoffset[1]))#>(-CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale))<#(CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale))
  pst.clearend
  pst.NewLine
  CurrentSourceShunt.offset(j)  
  if dp==dn
    if p==n
      if dp<p
        CurrentSourceShunt.set(((CurrentSourceShunt.get+CurrentSourceShunt.getstp*CurrentSourceShunt.getstepscale)#>0)//4601)
}

{PRI shuntgradient | i,n,p,dn,dp
  pst.position(0,10)
  pst.str(string("Shunt."))
    pst.clearend
  pst.newline
  pst.str(string(" Neg. offset: "))
  CurrentSourceShunt.decrement
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("Is = "))
  pst.dec(CurrentSourceShunt.get)
  dn := dac_p16.measure(avercnt)
  pst.str(string(" Pdir = "))
  pst.dec(dn)
  n := dac_p17.measure(avercnt)
  pst.str(string(" Pref = "))
  pst.dec(n)
  pst.clearend
  pst.newline
  pst.str(string(" Pos. offset: "))
  CurrentSourceShunt.increment
  CurrentSourceShunt.increment  
  waitcnt(CNT + magnetizationdelay)
  pst.str(string("Is = "))
  pst.dec(CurrentSourceShunt.get)
  p := dac_p16.measure(avercnt)
  pst.str(string(" Pdir = "))
  pst.dec(dp)
  p := dac_p17.measure(avercnt)
  pst.str(string(" Pref = "))
  pst.dec(p)
  pst.clearend
  pst.newline
  pst.str(string(" dPref/dIs = "))
  pst.dec(p-n)
  pst.str(string(" dPdir/dIs = "))
  pst.dec(dp-dn)
  pst.clearend
  CurrentSourceShunt.decrement
  if p > n
    'CurrentSourceShunt.offset(-4)
    CurrentSourceShunt.decrement
  if p < n
    'CurrentSourceShunt.offset(4)
    CurrentSourceShunt.increment
}


PRI execute | togglecounter, cogShunt, cogBallast, ShuntCurrent, BallastCurrent, cogDacP16, DacP16Value, cogDacP17, DacP17Value, directdecrement,direct,directincrement,reflecteddecrement,reflected,reflectedincrement,i,j,p,r
  togglecounter := 0
  waitcnt(CNT+3*80000000)
  pst.Start(250000)

  pst.NewLine
  pst.Str(string("Matching network controller started."))
  pst.NewLine

  pst.NewLine
  pst.str(string("Version "))
  pst.dec(version)
  pst.newline

  pst.NewLine
  pst.Str(string("Setting shunt inductor core magnetization current to zero."))
  pst.NewLine
  ShuntCurrent := CurrentSourceShunt.set(500)
  pst.Str(string("Shunt inductor core magnetization current was set to "))
  pst.dec(ShuntCurrent)
  pst.NewLine

  pst.NewLine
  pst.Str(string("Starting shunt inductor core magnetization current source."))
  pst.NewLine
  cogShunt := CurrentSourceShunt.start
  if cogShunt > -1
    pst.Str(string("Shunt inductor core magnetization current source is running in cog #"))
    pst.dec(cogShunt)
  else
    pst.Str(string("Error starting shunt inductor core magnetization current source."))
    pst.Stop
    return
  pst.NewLine

  pst.NewLine
  pst.Str(string("Setting ballast inductor core magnetization current to zero."))
  pst.NewLine
  BallastCurrent := CurrentSourceBallast.set(500)
  pst.Str(string("Ballast inductor core magnetization current was set to "))
  pst.dec(BallastCurrent)
  pst.NewLine

  pst.NewLine
  pst.Str(string("Starting ballast inductor core magnetization current source."))
  pst.NewLine
  cogBallast := CurrentSourceBallast.start
  if cogBallast > -1
    pst.Str(string("Ballast inductor core magnetization current source is running in cog #"))
    pst.dec(cogBallast)
  else
    pst.Str(string("Error starting ballast inductor core magnetization current source."))
    pst.Stop
    return
  pst.NewLine

  ' setting up DAC on p16 for comparator on p18 LM339/2 green input wire
  pst.newline
  pst.str(string("Setting DAC on p16 to 0."))
  pst.newline
  DacP16Value := dac_p16.set(0)
  pst.str(string("Setting DAC on p16 was set to "))
  pst.dec(DacP16Value)
  pst.newline
  cogDacP16 := dac_p16.start
  if cogDacP16 > -1
    pst.Str(string("DAC on P16 is running in cog #"))
    pst.dec(cogDacP16)
  else
    pst.Str(string("Error starting DAC on P16."))
    pst.Stop
    return
  pst.NewLine

  ' setting up DAC on p17 for comparator on p19 LM339/1 yellow input wire
  pst.newline
  pst.str(string("Setting DAC on p17 to 0."))
  pst.newline
  DacP17Value := dac_p17.set(0)
  pst.str(string("Setting DAC on p17 was set to "))
  pst.dec(DacP17Value)
  pst.newline
  cogDacP17 := dac_p17.start
  if cogDacP17 > -1
    pst.Str(string("DAC on P17 is running in cog #"))
    pst.dec(cogDacP17)
  else
    pst.Str(string("Error starting DAC on P17."))
    pst.Stop
    return
  pst.newLine
  pst.newline


  waitcnt(CNT+3*80000000)

  'terminal command interpreter
  repeat
    if pst.RxCount > 0
      'pst.Beep
      symbol := pst.CharIn
      case symbol
        "?":
          pst.newline
          pst.str(string("Matching Network Controller, Version "))
          pst.Dec(version)
          pst.newline
          pst.newline
          pst.str(string("Help:"))
          pst.newline
          pst.str(string("s / S - decrease / INCREASE shunt current"))
          pst.newline
          pst.str(string("b / B - decrease / INCREASE ballast current")) 
          pst.newline
          pst.str(string("d / D - decrease / INCREASE current step")) 
          pst.newline
        "s":
          pst.newline
          CurrentSourceShunt.decrement
          pst.str(string("shunt curent "))
          pst.dec(CurrentSourceShunt.get)
          pst.newline
        "S":
          pst.newline
          CurrentSourceShunt.increment
          pst.str(string("shunt curent "))
          pst.dec(CurrentSourceShunt.get)
          pst.newline
        "b":
          pst.newline
          CurrentSourceBallast.decrement
          pst.str(string("ballast curent "))
          pst.dec(CurrentSourceBallast.get)
          pst.newline
        "B":
          pst.newline
          CurrentSourceBallast.increment
          pst.str(string("ballast curent "))
          pst.dec(CurrentSourceBallast.get)
          pst.newline
        "d":
          pst.newline
          CurrentSourceShunt.stpdecrement
          pst.str(string("shunt curent step "))
          pst.dec(CurrentSourceShunt.getstp)
          pst.newline
          CurrentSourceBallast.stpdecrement
          pst.str(string("ballast curent step "))
          pst.dec(CurrentSourceBallast.getstp)
          pst.newline
        "D":
          pst.newline
          CurrentSourceShunt.stpincrement
          pst.str(string("shunt curent step "))
          pst.dec(CurrentSourceShunt.getstp)
          pst.newline
          CurrentSourceBallast.stpincrement
          pst.str(string("ballast curent step "))
          pst.dec(CurrentSourceBallast.getstp)
          pst.newline
        "0":
          pst.newline
          CurrentSourceShunt.set(1999)
          CurrentSourceBallast.set(1999)
        "1":
          pst.newline
          CurrentSourceBallast.set(0)
        "2":
          pst.newline
          CurrentSourceBallast.set(4600)
        "3":
          pst.newline
          CurrentSourceShunt.set(0)
        "4":
          pst.newline
          CurrentSourceShunt.set(4600)
        "+":
          if togglecounter < togglecntrmax
            togglecounter += 1
        "-":
          if togglecounter > 0
            togglecounter -= 1
        " ":
           pst.clear
 
    else
      case togglecounter
        4: slowfind
           togglecounter := 0 
        3: ballastgradient
           shuntgradient
        2: ballastgradient
         
       1: shuntgradient
          
       0: 
        'pst.str(string("dacs P16/P18 & P17/P19: "))
        'pst.dec(dac_p16.measure(avercnt))
        'pst.str(string(", "))
        'pst.dec(ina[18])
        'pst.str(string(", "))
        'pst.dec(dac_p17.measure(avercnt))
        'pst.str(string(", "))
        'pst.dec(ina[19])
        pst.str(string("Direct/Reflected/SWR: "))
        pst.dec(p:=getpower)
        pst.str(string(", "))
        pst.dec(r:=getreflected)
        pst.str(string(", "))
        pst.dec(calculateswr(p,r))
        pst.str(string("  Sunt/Ballast: "))
        pst.dec(CurrentSourceShunt.get)
        pst.str(string(", "))
        pst.dec(CurrentSourceBallast.get)
        pst.NewLine
        'waitcnt(2000+cnt)

     