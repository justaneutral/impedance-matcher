{{┌──────────────────────────────────────────┐
  │ EEPROM demo using my I2C driver          │
  │ Author: Chris Gadd                       │
  │ Copyright (c) 2012 Chris Gadd            │
  │ See end of file for terms of use.        │
  └──────────────────────────────────────────┘

  Demonstrates how to write a byte, write a string of bytes, read a byte, read consecutive bytes, and read a page of bytes using I2C 

     24LC256
    ┌───────┐                 
  ┌─┤A0  Vcc├─┘ 10KΩ         
  ┣─┤A1   WP├─┐ │                     1   2   3   4   5   6   7   8   9   0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5   6   7   8   9   0   1   2   3   4   5   6   7     
  ┣─┤A2  SCL├─┼─┼─    I2C Clock 
  ┣─┤Vss SDA├─┼─┻─    I2C Data  ────────────
   └───────┘                    S   1   0   1   0   0   0   0   0       x  a15 a14 a13 a12 a11 a10  a9  a8      a7  a6  a5  a4  a3  a2  a1  a0      d7  d6  d5  d4  d3  d2  d1  d0      P 
                                      └Device CODE┘   └─Chip──┘   │ (Ack)                 Byte address (0000 - 7FFF)                                                                        
                                                        Select    Read (1)                                                                                                                  
                                                        Bits      Write(0)                                    Receiver pulls SDA low to acknowledge                                         
}}                                                                                                                                                
CON
_clkmode = xtal1 + pll16x                                                      
_xinfreq = 5_000_000

SDA_pin = 29
SCL_pin = 28
Bitrate = 400_000

VAR
  byte  buffer[512]                  

OBJ
' I2C : "I2C Spin driver v1.1"
  I2C : "I2C PASM driver v1.3"
  'FDS : "FullDuplexSerial
  FDS : "Parallax Serial Terminal"

PUB Main | Idx
' I2C.start(SCL_pin,SDA_pin)
  I2C.start(SCL_pin,SDA_pin,bitrate)
  FDS.start({31,30,0,}115_200)
  waitcnt(clkfreq + cnt)                                                        ' Delay to allow the serial terminal to turn on

  FDS.char($00)
  FDS.str(string("Using single writes to store the values $01, $23, and $45 in EEPROM memory locations $1000, $1001, and $1002.",$0D,{
                }" Each write takes approximately 4ms to complete.",$0D,$0D))
  I2C.write(I2C#EEPROM,$1000,$01)                                               
  I2C.write(I2C#EEPROM,$1001,$23)                                               
  I2C.write(I2C#EEPROM,$1002,$45)                                               

  FDS.str(string("Using a page write to store 5 bytes to consecutive locations starting at $1003.",$0D,{
                }" A page can be written without delay, only requires ~4ms after the final byte.",$0D,$0D))
  I2C.write_page(I2C#EEPROM,$1003,@Test_data,5)

  FDS.str(string("Using a single read to read the byte stored at $1000:",$0D," "))                                                                                                                                                                                    
  FDS.hex(I2C.read(I2C#EEPROM,$1000),2)                                         

  FDS.str(string($0D,$0D,"Using a repeated read to read the bytes stored in the 7 addresses following $1000:",$0D," "))
  repeat 7
    FDS.hex(I2C.read_next(I2C#EEPROM),2)                                        ' Perform a repeated read to read the next ten bytes following the byte at address $1000
    FDS.char(" ")                                                                 '  and display each one on the serial terminal as it is read

  FDS.str(string($0D,$0D,"Using a page read to read the first 512 bytes of the EEPROM.",$0D))
  I2C.read_page(I2C#EEPROM,$0000,@buffer,512)                                   ' Read 512 bytes starting from address $0000, and store in the buffer
  Idx~                                                                          
  repeat 512 / 16                                                               ' Display the 512 bytes of buffer on serial terminal
    FDS.hex(Idx,4)                                                              '  Show the base address location for each row of 16 bytes
    FDS.char(" ")
    FDS.char(" ")
    repeat 16
      FDS.hex(buffer[Idx++],2)
      FDS.char(" ")
    FDS.char($0D)              
  

  repeat
    FDS.str(string($0D,">>>"))
    FDS.char(Counter)
    FDS.newline
    repeat while FDS.RxCount == 0
    Counter := FDS.CharIn
    FDS.str(string($0D,"Update a counter stored in EEPROM.  Each reset causes the the number to increment.",$0D," "))
    FDS.char(counter)                                                            ' Display counter value - loaded automatically from EEPROM on each reset
    I2C.write(I2C#EEPROM,@Counter,Counter)
                                        ' Increment the counter and store back in to EEPROM 
      

DAT                     org
Test_data               byte      $67,$89,$AB,$CD,$EF
Counter                 byte      00                                            ' Initializes counter to 0, value gets incremented by the program
                                                                                '  Storing this program in EEPROM and resetting causes the
                                                                                '  incremented value to be used
                        fit
                                  