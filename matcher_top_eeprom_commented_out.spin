'matcher top entry is here

CON
  maxrestartcnt = 365
  resetcode = 4228
  menupositionA = 20
  menupositionG = 21
  menuposition0 = 28
  menuposition1 = 30
  slowfindposition = 24
  finddpbposition = 25
  finddpsposition = 26
  
  presetindexmax = 1
  presetindexmax1 = presetindexmax+1
  togglecntrmax = 5
  version = 20140627
  avercnt = 1
  dempfer = 64
  scaler = 8
  magnetizationdelay = 10000000
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

OBJ

  pst                        : "Parallax Serial Terminal"
  CurrentSourceShunt         : "transformer_capacitor1mf_channel_A"
  CurrentSourceBallast       : "transformer_capacitor1mf_channel_B"
  dac_p16                    :  "dac_on_p16" 'used by comparator on P19
  dac_p17                    :  "dac_on_p17" 'used by comparator on P19
  eeprom                     : "EEPROM"
       

VAR  
  long togglemeasurements, newcnt, symbol, prevreflected
  long iterationcounter
  byte presetindex
  long presetflag[presetindexmax1],shuntpreset[presetindexmax1],ballastpreset[presetindexmax1],powerpreset[presetindexmax1],reflectedpreset[presetindexmax1]  

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
     
PRI calculateswr(curp,curr) : swr
  swr := curp-curr

PRI getpower : p
  p := dac_p16.measure(avercnt)

PRI getreflected : r
  r := dac_p17.measure(avercnt)

PRI finddpb : dpb | p,r,ob,pb,rb,drb,ofb,ncn
  p := getpower
  r := getreflected
  ob := (((32*r+2048)/(p+2048))#>1)<#256
  if CurrentSourceBallast.get > 2300
    ob := -ob
  CurrentSourceBallast.offset(ob)
  ncn:=cnt+magnetizationdelay
  pst.position(0,finddpbposition)
  pst.str(string("p=.... r=.... ob=... pb=.... rb=.... dpb=........ drb=........  b="))
  pst.clearend
  pst.position(2,finddpbposition)
  pst.dec(p)
  pst.position(9,finddpbposition)
  pst.dec(r)
  pst.position(17,finddpbposition)  
  waitcnt(ncn)
  pb := getpower
  rb := getreflected
  if ob > 0
    dpb := pb-p
    drb := rb-r
  else
    dpb := p-pb
    drb := r-rb
  CurrentSourceBallast.offset(-ob)  
  if drb < 1 or dpb > -1
    ofb := ob
  else
    ofb := -ob
  CurrentSourceBallast.offset(ofb)  
  'waitcnt(cnt+magnetizationdelay)  
  pst.dec(ofb)
  pst.position(24,finddpbposition)
  pst.dec(pb)
  pst.position(32,finddpbposition)
  pst.dec(rb)
  pst.position(41,finddpbposition)
  pst.dec(dpb)
  pst.position(54,finddpbposition)
  pst.dec(drb)
  pst.position(66,finddpbposition)
  pst.dec(CurrentSourceBallast.get)
  
PRI finddps : dps | p,r,os,ps,rs,drs,ofs,ncn
  p := getpower
  r := getreflected
  os := (((32*r+2048)/(p+2048))#>1)<#256
  if CurrentSourceShunt.get > 2300
    os := -os
  CurrentSourceShunt.offset(os)
  ncn:=cnt+magnetizationdelay
  pst.position(0,finddpsposition)
  pst.str(string("p=.... r=.... os=... ps=.... rs=.... dps=........ drs=........  s="))
  pst.clearend
  pst.position(2,finddpsposition)
  pst.dec(p)
  pst.position(9,finddpsposition)
  pst.dec(r)
  pst.position(17,finddpsposition)
  waitcnt(ncn)
  ps := getpower
  rs := getreflected
  if os > 0
    dps := ps-p
    drs := rs-r
  else
    dps := p-ps
    drs := r-rs
  CurrentSourceShunt.offset(-os)  
  if drs < 1 or dps > -1
    ofs := os
  else
    ofs := -os
  CurrentSourceShunt.offset(ofs)  
  'waitcnt(cnt+magnetizationdelay)  
  pst.dec(ofs)
  pst.position(24,finddpsposition)
  pst.dec(ps)
  pst.position(32,finddpsposition)
  pst.dec(rs)
  pst.position(41,finddpsposition)
  pst.dec(dps)
  pst.position(54,finddpsposition)
  pst.dec(drs)
  pst.position(66,finddpsposition)
  pst.dec(CurrentSourceShunt.get)
  
PRI slowfind | curp, curr, curb,curs,bestp,bestr,bests,bestb,swr
  'pst.clear
  pst.position(0,slowfindposition)
  pst.str(string("Setting shunt inductor to medium impedance"))
  pst.clearend
  pst.newline
  curs := 2000
  bests := curs
  CurrentSourceShunt.set(curs)
  pst.str(string("Setting ballast inductor to maximum impedance"))
  pst.clearend
  pst.newline
  CurrentSourceBallast.set(0)
  pst.str(string("Bringing ballast to resonance"))
  pst.clearend
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
  pst.clearend
  pst.newline
  repeat curb from CurrentSourceBallast.getstp to 4600 step CurrentSourceBallast.getstp
    CurrentSourceBallast.set(curb)
    waitcnt(cnt + magnetizationdelay)
    pst.position(0,slowfindposition+4)
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
    pst.clearend
  pst.position(0,slowfindposition+5)
  CurrentSourceBallast.set(bestb)
  pst.str(string("Adjusting shunt coil current"))
  pst.clearend
  pst.newline
  repeat curs from CurrentSourceShunt.getstp to 4600 step CurrentSourceShunt.getstp
    CurrentSourceShunt.set(curs)
    waitcnt(cnt + magnetizationdelay)
    pst.position(0,slowfindposition+6)
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
    pst.clearend
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
  pst.clearend

PRI autoselect | nextindex
  if presetflag[presetindex] =< 0 or (getpower=<powerpreset[presetindex] and getreflected=>reflectedpreset[presetindex]) 
    nextindex:=presetindex
    repeat
      nextindex:=(nextindex+1)//presetindexmax1
    until ((nextindex==presetindex) or (presetflag[nextindex]>0))  
    presetindex:=nextindex
    CurrentSourceShunt.set(shuntpreset[presetindex])
    CurrentSourceBallast.set(ballastpreset[presetindex])
    waitcnt(cnt+magnetizationdelay)

PRI execute | togglecounter,cogEEPROM,cogPst,cogShunt,cogBallast,ShuntCurrent,BallastCurrent,cogDacP16,DacP16Value,cogDacP17, DacP17Value, directdecrement,direct,directincrement,reflecteddecrement,reflected,reflectedincrement,i,j,p,r
  togglecounter := 0
  cogPst:=pst.Start(250000)
  pst.Str(string("Dourbal Electric. Matching network controller started."))
  pst.NewLine
  pst.str(string("Version "))
  pst.dec(version)
  pst.NewLine
  pst.str(string("Serial Interface Terminal is running in cog # "))
  pst.dec(cogPst)
  pst.NewLine
  cogShunt := CurrentSourceShunt.start
  if cogShunt > -1
    pst.Str(string("Shunt inductor core magnetization current source is running in cog #"))
    pst.dec(cogShunt)
  else
    pst.Str(string("Error starting shunt inductor core magnetization current source."))
    pst.Stop
  pst.NewLine
  cogBallast := CurrentSourceBallast.start
  if cogBallast > -1
    pst.Str(string("Ballast inductor core magnetization current source is running in cog #"))
    pst.dec(cogBallast)
  else
    pst.Str(string("Error starting ballast inductor core magnetization current source."))
    pst.Stop
  ' setting up DAC on p16 for comparator on p18 LM339/2 green input wire
  DacP16Value := dac_p16.set(0)
  cogDacP16 := dac_p16.start
  pst.newline
  if cogDacP16 > -1
    pst.Str(string("DAC on P16 is running in cog #"))
    pst.dec(cogDacP16)
  else
    pst.Str(string("Error starting DAC on P16."))
    pst.Stop
  DacP17Value := dac_p17.set(0)
  pst.newline
  cogDacP17 := dac_p17.start
  if cogDacP17 > -1
    pst.Str(string("DAC on P17 is running in cog #"))
    pst.dec(cogDacP17)
  else
    pst.Str(string("Error starting DAC on P17."))
    pst.Stop
  pst.newline
  iterationcounter:=0
  {cogEEPROM:=eeprom.init
  pst.str(string("EEPROM process is running in cog #"))
  pst.dec(cogEEPROM)
  if eeprom.checkrestartcounter(maxrestartcnt)
    pst.newline
    pst.str(string("Need Reset"))
    pst.newline
    togglecounter := 0
    repeat
     if pst.RxCount > 0
       togglecounter := 10*togglecounter + (pst.CharIn - "0")
       if togglecounter == resetcode
         eeprom.saverestartcounter(0)
         pst.Beep
  pst.str(string(" :: "))
  pst.dec(eeprom.readrestartcounter)
  pst.newline}
  presetindex:=0 'eeprom.readpresetindex
  repeat i from 0 to presetindexmax
    presetflag[i]:=127 'eeprom.readpresetflag(i)
    shuntpreset[i]:=150+i*200 'eeprom.readshuntpreset(i)
    ballastpreset[i]:=3000-1000*i 'eeprom.readballastpreset(i)
    powerpreset[presetindex]:=500 'eeprom.readpowerpreset(presetindex)    
    reflectedpreset[presetindex]:=3000 'eeprom.readreflectedpreset(presetindex)    
    pst.str(string(" Preset # "))
    pst.dec(i)
    pst.str(string(", Shunt "))
    pst.dec(shuntpreset[i])
    pst.str(string(", Ballast "))
    pst.dec(ballastpreset[i])
    pst.str(string(", Thresholds: Power "))
    pst.dec(powerpreset[i])
    pst.str(string(", Reflected "))
    pst.dec(reflectedpreset[i])
    if presetflag[i]
      pst.str(string(", ACTIVE"))
    else
      pst.str(string(", inactive"))
    if i == presetindex
      pst.str(string(", CURRENT"))
    pst.newline
  CurrentSourceShunt.set(shuntpreset[presetindex])
  CurrentSourceBallast.set(ballastpreset[presetindex])
  'terminal command interpreter
  repeat
    if pst.RxCount > 0
      'pst.Beep
      symbol := pst.CharIn
      case symbol
        "s": CurrentSourceShunt.decrement
        "S": CurrentSourceShunt.increment
        "b": CurrentSourceBallast.decrement
        "B": CurrentSourceBallast.increment
        "d": CurrentSourceShunt.stpdecrement
             CurrentSourceBallast.stpdecrement
        "D": CurrentSourceShunt.stpincrement
             CurrentSourceBallast.stpincrement
        " ": pst.clear
        13:  presetindex:=(presetindex+1)//presetindexmax1
             'presetflag[presetindex]:=eeprom.readpresetflag(presetindex)
             CurrentSourceShunt.set(shuntpreset[presetindex])
             CurrentSourceBallast.set(ballastpreset[presetindex])
        8:   presetindex:=(presetindex+presetindexmax)//presetindexmax1
             'presetflag[presetindex]:=eeprom.readpresetflag(presetindex)
             CurrentSourceShunt.set(shuntpreset[presetindex])
             CurrentSourceBallast.set(ballastpreset[presetindex])
        "w": shuntpreset[presetindex]:=CurrentSourceShunt.get
             ballastpreset[presetindex]:=CurrentSourceBallast.get
             presetflag[presetindex]:=1
             powerpreset[presetindex]:=getpower
             reflectedpreset[presetindex]:=getreflected
             'eeprom.savepresetindex(presetindex)
             'eeprom.saveshuntpreset(presetindex,shuntpreset[presetindex])
             'eeprom.saveballastpreset(presetindex,ballastpreset[presetindex])
             'eeprom.savepresetflag(presetindex,presetflag[presetindex])
             'eeprom.savepowerpreset(presetindex,powerpreset[presetindex])
             'eeprom.savereflectedpreset(presetindex,reflectedpreset[presetindex])
        "t": presetflag[presetindex]:=0
             'eeprom.savepresetflag(presetindex,presetflag[presetindex])
             presetflag[presetindex]:=127
        "T": 'eeprom.savepresetflag(presetindex,presetflag[presetindex])
        "p": powerpreset[presetindex]:=(powerpreset[presetindex]+5901)//6001
             'eeprom.savepowerpreset(presetindex,powerpreset[presetindex])
        "P": powerpreset[presetindex]:=(powerpreset[presetindex]+100)//6001
             'eeprom.savepowerpreset(presetindex,powerpreset[presetindex])
        "r": reflectedpreset[presetindex]:=(reflectedpreset[presetindex]+5901)//6001
             'eeprom.savereflectedpreset(presetindex,reflectedpreset[presetindex])
        "R": reflectedpreset[presetindex]:=(reflectedpreset[presetindex]+100)//6001
             'eeprom.savereflectedpreset(presetindex,reflectedpreset[presetindex])
        "a": togglecounter &= 2
             iterationcounter:=0
             pst.position(0,menupositionA)
             pst.str(string(" Automatic Preset Selection Process stopped "))
             pst.clearend
        "A": togglecounter |= 1
             iterationcounter:=0
             pst.position(0,menupositionA)
             pst.str(string(" Automatic Preset Selection Process STARTED "))
             pst.clearend
        "g": togglecounter &= 1
             iterationcounter:=0        
             pst.position(0,menupositionG)
             pst.str(string(" Automatic Preset Adjustment Process stopped "))
             pst.clearend
        "G": togglecounter |= 2
             iterationcounter:=0
             pst.position(0,menupositionG)
             pst.str(string(" Automatic Preset Adjustment Process STARTED "))
             pst.clearend
        "f": slowfind
        "@": autoselect
        "#": reboot
        "?":
          pst.clear
          pst.newline
          pst.str(string(" Dourbal Electric, inc. www.dourbalelectric.com"))
          pst.newline
          pst.newline
          pst.str(string(" Matching Network Controller, Version "))
          pst.Dec(version)
          pst.newline
          pst.newline
          pst.str(string(" Help:"))
          pst.newline
          pst.str(string(" S / s - INCREASE / decrease shunt current"))
          pst.newline
          pst.str(string(" B / b - INCREASE / decrease ballast current")) 
          pst.newline
          pst.str(string(" D / d - INCREASE / decrease step"))
          pst.newline
          pst.str(string("   w   - Save current preset"))
          pst.newline
          pst.str(string(" T / t - Toggle current preset to ACTIVE / inactive state"))
          pst.newline
          pst.str(string(" P / p - INCREASE / decrease direct power threshold"))
          pst.newline
          pst.str(string(" R / r - INCREASE / decrease reflected power threshold"))
          pst.newline
          pst.str(string(" <ENTER> / <BACKSPACE> - increase / decrease current preset index"))
          pst.newline
          pst.str(string(" A / a - START / stop automatic preset selection process"))
          pst.newline
          pst.str(string(" G / g - START / stop preset adjustment process"))
          pst.newline
          pst.str(string(" f - Iterate through entire shunt & ballast ranges to find optimal point"))
          pst.newline
          
        {"0": CurrentSourceShunt.set(1999)
             CurrentSourceBallast.set(1999)
        "1": CurrentSourceShunt.set(0)
             CurrentSourceBallast.set(0)
        "2": CurrentSourceShunt.set(4600)
             CurrentSourceBallast.set(0)
        "3": CurrentSourceShunt.set(0)
             CurrentSourceBallast.set(4600)
        "4": CurrentSourceShunt.set(4600)
             CurrentSourceBallast.set(4600)}
    else
        if togglecounter & 1
          iterationcounter++
          pst.position(45,menupositionA)
          pst.dec(iterationcounter)
          pst.clearend
          autoselect
        if togglecounter & 2
          iterationcounter++
          pst.position(46,menupositionG)
          pst.dec(iterationcounter)
          pst.clearend
          finddpb
          finddps

        pst.position(0,menuposition0)
        pst.str(string(" Preset: "))
        pst.dec(presetindex+1)
        pst.str(string(" of "))
        pst.dec(presetindexmax1)
        if presetflag[presetindex]
          pst.str(string(" ACTIVE"))
        else
          pst.str(string(" inactive"))
        pst.str(string(". Power & Reflected thresholds: "))
        pst.dec(powerpreset[presetindex])':=eeprom.readpowerpreset(presetindex))
        pst.str(string(", "))
        pst.dec(reflectedpreset[presetindex])':=eeprom.readreflectedpreset(presetindex))  
        pst.clearend

        pst.position(0,menuposition1)
        pst.str(string(" Sunt: "))
        pst.dec(CurrentSourceShunt.get)
        pst.str(string(", Ballast: "))
        pst.dec(CurrentSourceBallast.get)
        pst.str(string(" Steps: shunt "))
        pst.dec(CurrentSourceShunt.getstp)
        pst.str(string(", ballast "))
        pst.dec(CurrentSourceBallast.getstp)
        pst.str(string(", Power: direct "))
        pst.dec(p:=getpower)
        pst.str(string(", reflected "))
        pst.dec(r:=getreflected)
        pst.clearend
      
      'waitcnt(2000+cnt)
     