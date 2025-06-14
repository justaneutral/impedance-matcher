CON
SDA_pin = 29
SCL_pin = 28
Bitrate = 400_000

OBJ
' I2C : "I2C Spin driver v1.1"
  I2C : "I2C PASM driver v1.3"

VAR
  byte buffer[4]

PUB init : cog
' cog := I2C.start(SCL_pin,SDA_pin)
  cog := I2C.start(SCL_pin,SDA_pin,bitrate)
'  waitcnt(clkfreq + cnt)                                                        ' Delay to allow the serial terminal to turn on

PUB savetogglecntr(index)
  I2C.write(I2C#EEPROM,@togglecntrstorage,index)

PUB readtogglecntr : index
  index:=I2C.read(I2C#EEPROM,@togglecntrstorage)

PUB savenextselectioncntrmax(index)
  I2C.write(I2C#EEPROM,@nextselectioncntrmaxstorage,index)

PUB readnextselectioncntrmax : index
  index:=I2C.read(I2C#EEPROM,@nextselectioncntrmaxstorage)

PUB savepresetindex(index)
  I2C.write(I2C#EEPROM,@indexstorage,index)

PUB readpresetindex : index
  index:=I2C.read(I2C#EEPROM,@indexstorage)

PUB savepresetflag(index,data) | buf
  buf:=data
  I2C.write(I2C#EEPROM,@presetflag+index,@buf)

PUB readpresetflag(index) : data | i 
  data:=I2C.read(I2C#EEPROM,@presetflag+index)

PUB saveshuntpreset(index,data) | buf
  buf:=data
  I2C.write_page(I2C#EEPROM,@shuntpreset+index<<2,@buf,4)

PUB readshuntpreset(index) : data | i 
  data.byte[0]:=I2C.read(I2C#EEPROM,@shuntpreset+index<<2)
  repeat i from 1 to 3
    data.byte[i]:=I2C.read_next(I2C#EEPROM)

PUB saveballastpreset(index,data) | buf
  buf:=data
  I2C.write_page(I2C#EEPROM,@ballastpreset+index<<2,@buf,4)

PUB readballastpreset(index) : data | i 
  data.byte[0]:=I2C.read(I2C#EEPROM,@ballastpreset+index<<2)
  repeat i from 1 to 3
    data.byte[i]:=I2C.read_next(I2C#EEPROM)

PUB savepowerpreset(index,data) | buf
  buf:=data
  I2C.write_page(I2C#EEPROM,@powerpreset+index<<2,@buf,4)

PUB readpowerpreset(index) : data | i 
  data.byte[0]:=I2C.read(I2C#EEPROM,@powerpreset+index<<2)
  repeat i from 1 to 3
    data.byte[i]:=I2C.read_next(I2C#EEPROM)

PUB savereflectedpreset(index,data) | buf
  buf:=data
  I2C.write_page(I2C#EEPROM,@reflectedpreset+index<<2,@buf,4)

PUB readreflectedpreset(index) : data | i 
  data.byte[0]:=I2C.read(I2C#EEPROM,@reflectedpreset+index<<2)
  repeat i from 1 to 3
    data.byte[i]:=I2C.read_next(I2C#EEPROM)

PUB readrestartcounter : data | i 
  data.byte[0]:=I2C.read(I2C#EEPROM,@restartcounter)
  repeat i from 1 to 3
    data.byte[i]:=I2C.read_next(I2C#EEPROM)

PUB saverestartcounter(data) | buf
  buf:=data
  I2C.write_page(I2C#EEPROM,@restartcounter,@buf,4)

PUB checkrestartcounter(maxcnt) : y | x
  x:=readrestartcounter+1
  y:=(x>maxcnt) 
  saverestartcounter(x)

DAT                             org
restartcounter                  long    0
shuntpreset                     long    0,0,0,0,0,0,0,0,0,0
ballastpreset                   long    0,0,0,0,0,0,0,0,0,0
powerpreset                     long    0,0,0,0,0,0,0,0,0,0
reflectedpreset                 long    0,0,0,0,0,0,0,0,0,0
presetflag                      byte    0,0,0,0,0,0,0,0,0,0       
indexstorage                    byte    0
togglecntrstorage               byte    0
nextselectioncntrmaxstorage     byte 0
                                fit