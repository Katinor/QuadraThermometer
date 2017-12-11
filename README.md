# QuadraThermometer
Super Great Thermometer on PIC16F876A

current Version : 0.0.3


- [Requirements](#requirements)
- [Installation](#installation)
- [TODO](#todo)
- [MODE](#mode)

# Requirements
- PIC16F876A
- LM35 Temperature Sensors(National Semiconductor)
- OP-AMP (LM358 or HA17358)
- FND (CC)

# Installation
- RA0 - Thermometer
- RA1 - FND - G
- RA2 - FND - COM2
- RA3 - FND - COM1
- RA4 - BUZZER (pull-up)
- RA5 - 
- RA6 - 
- RA7 -
- RB0 - FND - DP
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

# MODE
- Clock
  - LED 1 is ON
  - button A to change view (H:M <-> M:S)
  - button B to call Thermometer MODE
  - button C to call Clock Setting MODE
- Thermometer
  - LED 2 is ON
  - button A to push a stack
  - button B to call Clock MODE
  - button C to call POP MODE
- Clock Setting
  - LED 1 is on
  - button A to make value up
  - button B to make value down
  - button C to go next step
  - when change current SEC, button A and B may reset it
- POP - Clock
  - button A to change view
  - button B to call POP - Thermometer MODE
  - button C to pop a stack
- POP - Thermometer
  - button A do nothing
  - button B to call POP - Clock MODE
  - button C to pop a stack

# TODO
- (COMPLETE) Remake CONV subroutine (Out of Date)
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