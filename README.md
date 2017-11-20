# QuadraThermometer
Super Great Thermometer on PIC16F876A

- [Requirements](#requirements)
- [Installation](#installation)
- [TODO](#todo)

# Requirements
- PIC16F876A
- LM35 Temperature Sensors(National Semiconductor)
- OP-AMP (LM358 or HA17358)
- FND (CC)

# Installation
- RA0 - FND - DP
- RA1 - FND - G
- RA2 - FND - COM2
- RA3 - FND - COM1
- RA4 - BUZZER (pull-up)
- RA5 - 
- RA6 - 
- RA7 -
- RB0 -
- RB1 - FND - COM4
- RB2 - FND - COM3
- RB3 - SW1
- RB4 - SW2
- RB5 - SW3
- RB6 - MOLEX5 - 5
- RB7 - LED anode common & MOLEX5 - 4
- RC0 - FND - E
- RC1 - FND - D
- RC2 - FND - F
- RC3 
- RC4
- RC5 - FND - C
- RC6 - FND - B
- RC7 - FND - A

# TODO
- Remake CONV subroutine (Out of Date)
- Get value to thermometer
  - Thermometer -> *3 (AMP-circuit) -> *1.5 (Opt)
- Make Storage system
  - STACK
- Button System
  - When clock
    - 1- PUSH 2- clock modify 3-H/M to M/S -> thermo
  - When clock modify
    - 1- increase 2-decrease 3-next
  - When thermometer
    - 1- PUSH 2- POP mode 3- clock
  - When POP mode
    - 1- select view 2- POP 3- EXIT

# NOTICE
Currently, subroutine ```DISP``` just use RC[0:7] and RA[0:3], and use CA.