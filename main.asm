PROCESSOR 16F876
#INCLUDE <P16F876A.inc>
; --- STATUS BITS -----
IR EQU 7
RP1 EQU 6
RP0 EQU 5
NOT_TO EQU 4
NOT_PD EQU 3
ZF EQU 2
DC EQU 1
CF EQU 0
; -- OPTION BITS -----
W EQU B'0'
F EQU .1

; -- GPR --
GP_STATUS EQU 20H ; for global control
SWT_STATUS EQU 21H ; for control major flags
MOD_STATUS EQU 22H ; for control mode
CLK_STATUS EQU 23H ; for control clock flags
SP_STATUS EQU 24H ; for check 0.25sec
STACK_NUM EQU 25H ; for save the number of stack

; backup buffer for interrupt
W_TEMP EQU 26H
S_TEMP EQU 27H
PC_TEMP EQU 28H
; for check time
INT_CNT EQU 29H
B_DELAY EQU 2AH
BT_DELAY EQU 2BH

; for use Analog data control
RET_VOL EQU 2CH
ANL_CNT EQU 2DH
TBF_CNT EQU 2EH
TBF_BF EQU 2FH
THBF_HALF EQU 30H
THBF_1 EQU 31H
THBF_2 EQU 32H
THBF_3 EQU 33H
THBF_4 EQU 34H
T_1 EQU 35H
T_10 EQU 36H
T_100 EQU 37H
CR_TH EQU 38H ; CuRrent THermometer value
CR_TH_LAP EQU 39H
CR_TH_BUFF EQU 3AH

;DISP BUFFER
DISPBF_1 EQU 3BH
DISPBF_2 EQU 3CH
DISPBF_3 EQU 3DH
DISPBF_4 EQU 3EH

; define pointer's start - 40 ~ 5F
S_BUF EQU 40H

;CLOCK
D_1SEC EQU 60H
D_10SEC EQU 61H
D_1MIN EQU 62H
D_10MIN EQU 63H
D_1HR EQU 64H
D_10HR EQU 65H
D_THR EQU 66H
D_1SEC_B EQU 67H
D_10SEC_B EQU 68H
D_1MIN_B EQU 69H
D_10MIN_B EQU 6AH
D_1HR_B EQU 6BH
D_10HR_B EQU 6CH

MAIN_BF EQU 6DH
STACK_BF EQU 6EH

; -- GPR BIT
;0-3 : FND COMMON set
INT_SWT1 EQU 0
INT_SWT2 EQU 1
INT_SWT3 EQU 2
INT_SWT4 EQU 3
;4-7 : FND dot set
DOT_SWT1 EQU 4
DOT_SWT2 EQU 5
DOT_SWT3 EQU 6
DOT_SWT4 EQU 7

; -- SPR BIT
;0 : H/M or M/S
HM_CONV EQU 0
;1 : Button Enable Flag
BT_ENABLE EQU 1
;2 : ANALOG Input Enable Flag
ANL_ENABLE EQU 2
;3 : LAP existance
LAP_EXT EQU 3
;4 : LAP overflow
LAP_OV EQU 4
;5~7 : LED dot set
LED_SWT3 EQU 5
LED_SWT2 EQU 6
LED_SWT1 EQU 7

; -- MDR BIT
;0 : Thermometer
MODE1 EQU 0
;1 : Clock
MODE2 EQU 1
;2 : Clock : Mody
MODE3 EQU 2
;3 : Ther : Lap_Check
MODE4 EQU 3
;4 : Buzzer control
B_ENABLE EQU 4
;5 : Analog check complete
AD_DONE EQU 5
;6 : ANL_MEAN_MODULATOR
HALF_CHECK EQU 6

; -- CLK BIT
;0 : HOUR
HOUR EQU 0
;1 : MIN
MIN EQU 1
;2 : SEC
SEC EQU 2


; -- SP-STATUS
;0~4 : Timer Counter
DOT_CHECK1 EQU 0
DOT_CHECK2 EQU 1
DOT_SEC EQU 2
DOT_HALF EQU 3 ; NOT USED
DOT_QUADRA EQU 4 ; NOT USED

; -- start
ORG 0
GOTO START_UP

; Interupt routine
ORG 4
	MOVWF W_TEMP
	SWAPF STATUS,W
	MOVWF S_TEMP

	BTFSC PIR1,6
	CALL A_INTR
	BTFSC INTCON,2 ;
	CALL DISP

	SWAPF S_TEMP,W
	MOVWF STATUS
	SWAPF W_TEMP,F
	SWAPF W_TEMP,W
	RETFIE
;######################
; D_CONV
; BIT :
; 7 6 5 4 3 2 1 0
; A B C G . F D E
;######################
D_CONV
	ANDLW 0FH
	ADDWF PCL,F
	RETLW B'11100111' ;0
	RETLW B'01100000' ;1
	RETLW B'11010011' ;2
	RETLW B'11110010' ;3
	RETLW B'01110100' ;4
	RETLW B'10110110' ;5
	RETLW B'10110111' ;6
	RETLW B'11100000' ;7
	RETLW B'11110111' ;8
	RETLW B'11110110' ;9
	RETLW B'00010000' ;-
	RETLW B'11111111' ;Test
	RETLW B'11100101' ;C
	RETLW B'00001000' ;.
	RETLW B'00110111' ;E
	RETLW B'00010111' ;F
	
;######################
; DISP
; DISP 1~4 -> LED control
;######################
DISP
	CALL BTD_MOD
	CALL ANL_MOD
	BSF PORTA, 3 
	BSF PORTA, 2 
	BSF PORTB, 2 
	BSF PORTB, 1 
	BTFSC GP_STATUS, INT_SWT1
	GOTO DISP1
	BTFSC GP_STATUS, INT_SWT2
	GOTO DISP2
	BTFSC GP_STATUS, INT_SWT3
	GOTO DISP3
	BTFSC GP_STATUS, INT_SWT4
	GOTO DISP4
	GOTO DISP_LED
DISP1
	MOVF DISPBF_1,W
	CALL D_CONV
	MOVWF PORTC
	BTFSC GP_STATUS,DOT_SWT1
	BSF PORTC,3
	CALL P_CONV
	BCF PORTA,3
	BCF GP_STATUS,INT_SWT1
	BSF GP_STATUS,INT_SWT2
	BCF INTCON,2
	RETURN
DISP2
	MOVF DISPBF_2,W
	CALL D_CONV
	MOVWF PORTC
	BTFSC GP_STATUS,DOT_SWT2
	BSF PORTC,3
	CALL P_CONV
	BCF PORTA,2
	BCF GP_STATUS,INT_SWT2
	BSF GP_STATUS,INT_SWT3
	BCF INTCON,2
	RETURN
DISP3
	MOVF DISPBF_3,W
	CALL D_CONV
	MOVWF PORTC
	BTFSC GP_STATUS,DOT_SWT3
	BSF PORTC,3
	CALL P_CONV
	BCF PORTB,2
	BCF GP_STATUS,INT_SWT3
	BSF GP_STATUS,INT_SWT4
	BCF INTCON,2
	RETURN
DISP4
	MOVF DISPBF_4,W
	CALL D_CONV
	MOVWF PORTC
	BTFSC GP_STATUS,DOT_SWT4
	BSF PORTC,3
	CALL P_CONV
	BCF PORTB,1
	BCF GP_STATUS,INT_SWT4
	BCF INTCON,2
	RETURN
DISP_LED
	CLRF PORTC
	BCF PORTB,7
	BTFSS SWT_STATUS,LED_SWT1
	BSF PORTC,7
	BTFSS SWT_STATUS,LED_SWT2
	BSF PORTC,6
	BTFSS SWT_STATUS,LED_SWT3
	BSF PORTC,5
	BSF PORTB,7
	BSF GP_STATUS,INT_SWT1
	INCF INT_CNT,F
	BCF INTCON,2
	RETURN

;######################
; P_CONV
; PORTC[4] -> PORTA[1]
; PORTC[3] -> PORTB[0]
;######################
P_CONV
	BSF 		PORTA, 1
	BTFSS 		PORTC, 4
	BCF 		PORTA, 1
	BSF 		PORTB, 0
	BTFSS 		PORTC, 3
	BCF 		PORTA, 0
	RETURN

;######################
; ANL_MOD
; get some cool-down for ADC
;######################
ANL_MOD
	BTFSC SWT_STATUS,ANL_ENABLE
	RETURN
	MOVF ANL_CNT,W
	BTFSC STATUS,ZF
	GOTO ANL_GO,F
	DECF ANL_CNT,F
	RETURN
ANL_GO
	BSF SWT_STATUS,ANL_ENABLE
	BSF ADCON0,2
	RETURN

;######################
; A_INTR
;######################
A_INTR
	MOVF ADRESH,W
	MOVWF RET_VOL
	BCF PIR1,6
	BSF MOD_STATUS,AD_DONE
	MOVLW .32
	MOVWF ANL_CNT
	BCF SWT_STATUS,ANL_ENABLE
	RETURN

;######################
; BTD_MOD & BEEP_MOD
; check time to use button and buzzer
;######################
BTD_MOD
	MOVF BT_DELAY,W
	BTFSC STATUS,ZF
	GOTO BEEP_MOD
	DECF BT_DELAY,F
BEEP_MOD
	MOVF B_BEEP,W
	BTFSC STATUS,ZF
	GOTO L_LOOP1
	DECF B_BEEP,F
	RETURN

	;--main
START_UP
	BSF STATUS,RP0 ; BANK 1
;######################
; PORTA
; 0 = Thermometer
; 1:3 = FND (G, COM2, COM1)
; 4 = buzzer
;######################
	MOVLW B'00000001'
	MOVWF TRISA
;######################
; PORTB
; 0:2 = FND (DP, COM4, COM3)
; 3:5 = button
; 6:7 = MOLEX5 (5, 4)
; 7 also used on diode common
;######################
	MOVLW B'00111000'
	MOVWF TRISB
;######################
; PORTC
; 0:2 = FND (E, D, F)
; 5:7 = FND (C, B, A)
;######################
	MOVLW B'00000000'
	MOVWF TRISC
;######################
; OPTION_REG
; Timer 0 overflow after 1.024ms
; 975 * 1.024 = 998.4 ms
;######################
	MOVLW B'00000001'
	MOVWF OPTION_REG
;######################
; ADCON1
; Left-Justified
; {D,D,D,D,D,D,D,A}
;######################
	MOVLW B'00001110'
	MOVWF ADCON1
	BCF STATUS,RP0 ; BANK 0
;######################
; ADCON0
; Fosc/32
; use RA0 to AN0
;######################
	MOVLW B'10000001'
	MOVWF ADCON0
	CLRF PIR1
	CLRF PIE1
	BSF PIE1,6 ; ADC Interrupt Enable bit
	BSF INTCON,5 ; Timer 0 Interrupt Enable bit
	BSF INTCON,6 ; Peripheral Interrupt Enable bit
	BSF INTCON,7 ; Global Interrupt Enable bit
DEFAULT_ST
	CLRF GP_STATUS
	CLRF SWT_STATUS
	MOVLW B'00000001'
	MOVWF MOD_STATUS
	CLRF MOD_STATUS
	CLRF CLK_STATUS
	CLRF SP_STATUS
	CLRF STACK_NUM
	CLRF INT_CNT
	CLRF INT_CNT
	CLRF B_DELAY
	CLRF BT_DELAY
	CLRF TBF_CNT
	CLRF ANL_CNT
	CLRF D_1SEC
	CLRF D_10SEC
	CLRF D_1MIN
	CLRF D_10MIN
	CLRF D_1HR
	CLRF D_10HR
	CLRF D_THR
LOOP_START
CK_LPS
	MOVLW .49
	SUBWF INT_CNT,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	GOTO DOT_LOOP
DOT_LOOP
	CLRF INT_CNT
	MOVF SP_STATUS,W
	ANDLW B'00000011'
	MOVWF MAIN_BF
	MOVLW .3
	SUBWF MAIN_BF,W
	BTFSC STATUS,ZF	
	GOTO CK_LOOP_S
	INCF SP_STATUS,F
	GOTO XLOOP
CK_LOOP_S
	INCF INT_CNT
	BCF SP_STATUS, DOT_CHECK2
	BCF SP_STATUS, DOT_CHECK1
	BTFSS SP_STATUS, DOT_SEC
	GOTO CK_LOOP_S2
	BCF SP_STATUS,DOT_SEC
	GOTO CK_LOOP
CK_LOOP_S2
	BSF SP_STATUS,DOT_SEC
	GOTO CK_LOOP
CK_LOOP
	INCF D_1SEC
	MOVLW .10
	SUBWF D_1SEC,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	CLRF D_1SEC
	INCF D_10SEC
	MOVLW .6
	SUBWF D_10SEC,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	CLRF D_10SEC
	INCF D_1MIN
	MOVLW .10
	SUBWF D_1MIN,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	CLRF D_1MIN
	INCF D_10MIN
	MOVLW .6
	SUBWF D_10MIN,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	CLRF D_10MIN
	INCF D_1HR
	INCF D_THR
	MOVLW .10
	SUBWF D_1HR,W
	BTFSS STATUS,ZF
	GOTO CK_LOOP_2
	CLRF D_1HR
	INCF D_10HR
	GOTO XLOOP
CK_LOOP_2
	MOVLW .24
	SUBWF D_THR,W
	BTFSS STATUS,ZF
	GOTO XLOOP
	CLRF D_THR
	CLRF D_1HR
	CLRF D_10HR
	GOTO XLOOP
XLOOP
	GOTO DISPBF_CONTROL
XLOOP_END
THLOOP
	BTFSC MOD_STATUS,AD_DONE
	CALL TH_CONTROL
BT_LOOP
;######################
; Way to check Button-Input
; 1. Chattering delay is zero? -> if true, ignore input signal.
; 2. Button is floating? -> if false, ignore input signal. (until button is floating)
; 3. goto subroutine
;######################
	MOVF BT_DELAY,W
	BTFSS STATUS,ZF
	GOTO L_LOOP
	BTFSC SWT_STATUS,BT_ENABLE
	GOTO BT_LOOP1
BT_CHECK
	MOVF PORTB,W
	ANDLW B'00011100'
	XORLW B'00011100'
	BTFSS STATUS,ZF
	GOTO L_LOOP
	BSF SWT_STATUS,BT_ENABLE	
BT_LOOP1
	BTFSC PORTB,3
	GOTO BT_LOOP2
	BCF SWT_STATUS,BT_ENABLE
	CALL BEEP_2
	MOVLW 7FH
	MOVWF BT_DELAY
	CALL BT_1
	GOTO L_LOOP
BT_LOOP2
	BTFSC PORTB,4
	GOTO BT_LOOP3
	BCF SWT_STATUS,BT_ENABLE
	CALL BEEP_2
	MOVLW 7FH
	MOVWF BT_DELAY
	CALL BT_2
	GOTO L_LOOP
BT_LOOP3
	BTFSC PORTB,5
	GOTO L_LOOP
	BCF SWT_STATUS,BT_ENABLE
	CALL BEEP_2
	MOVLW 7FH
	MOVWF BT_DELAY
	CALL BT_3
	GOTO L_LOOP
BT_LOOP_END
L_LOOP
	CALL BUZZ_BEEP_MOD
	CALL BUZZ_CTR
	GOTO LOOP_START

;######################
;Buzzer is on when B_BEEL > 0 && B_BEEPALLOW == 0 && B_BEEPTEMPO == 0
;######################
BUZZ_CTR
	MOVF B_BEEP,W
	BTFSC STATUS,ZF	
	GOTO BUZZ_OFF
	BTFSC MOD_STATUS,B_BEEPALLOW
	GOTO BUZZ_OFF
	BTFSC MOD_STATUS,B_BEEPTEMPO
	GOTO BUZZ_OFF
BUZZ_ON
	BSF PORTA,4
	RETURN
BUZZ_OFF
	BCF PORTA,4
	RETURN

;######################	
; if (B_BEEP == 0)
;  B_BEEP_CNT--; B_BEEP = 122;
;  B_PRES == 1 : B_BEEP / 2;
; if (B_BEEP_CNT == 0)
;  B_BEEP_EB--; B_BEEP_CNT = 8;
; When B_BEEP_EB decrease, B_BEEPTEMPO toggle.
; When B_BEEP_CNT decrease, B_BEEPALLOW toggle.
;######################
BUZZ_BEEP_MOD
	MOVF B_BEEP
	BTFSS STATUS, ZF
	RETURN
	MOVF B_BEEP_CNT
	BTFSS STATUS,ZF
	GOTO BEEP_MAIN
BEEP_SWT2
	MOVF B_BEEP_EB
	BTFSC STATUS,ZF
	RETURN
	DECF B_BEEP_EB
	MOVLW .8
	MOVWF B_BEEP_CNT
	BCF MOD_STATUS,B_BEEPALLOW
	BTFSC MOD_STATUS,B_BEEPTEMPO
	GOTO CLEAR_BEEPTEM
	BSF MOD_STATUS,B_BEEPTEMPO
	GOTO BEEP_MAIN
CLEAR_BEEPTEM
	BCF MOD_STATUS,B_BEEPTEMPO
	GOTO BEEP_MAIN
BEEP_MAIN
	DECF B_BEEP_CNT
	BTFSC MOD_STATUS,B_PRES
	GOTO BEEP_MAIN1
	MOVLW .122
	GOTO BEEP_MAIN2
BEEP_MAIN1
	MOVLW .61
BEEP_MAIN2
	MOVWF B_BEEP
	BTFSC MOD_STATUS,B_BEEPALLOW
	GOTO CLEAR_BEEP
	BSF MOD_STATUS,B_BEEPALLOW
	RETURN
CLEAR_BEEP
	BCF MOD_STATUS,B_BEEPALLOW
	RETURN
BEEP_1 ; beep 0.5sec
	CLRF B_BEEP_CNT
	CLRF B_BEEP_EB
	MOVLW .244
	MOVWF B_BEEP
	BCF MOD_STATUS,B_BEEPALLOW
	BCF MOD_STATUS,B_BEEPTEMPO
	RETURN
BEEP_2 ; beep very short
	CLRF B_BEEP_CNT
	CLRF B_BEEP_EB
	MOVLW .15
	MOVWF B_BEEP
	BCF MOD_STATUS,B_BEEPALLOW
	BCF MOD_STATUS,B_BEEPTEMPO
	RETURN
BEEP_3 ; beep-beep-!
	CLRF B_BEEP
	CLRF B_BEEP_EB
	MOVLW .4
	MOVWF B_BEEP_CNT
	BCF MOD_STATUS,B_BEEPALLOW
	BCF MOD_STATUS,B_BEEPTEMPO
	BCF MOD_STATUS,B_PRES
	RETURN
BEEP_4 ; beep * 4
	CLRF B_BEEP
	CLRF B_BEEP_CNT
	MOVLW .8
	MOVWF B_BEEP_EB
	BSF MOD_STATUS,B_BEEPALLOW
	BSF MOD_STATUS,B_BEEPTEMPO
	BSF MOD_STATUS,B_PRES
	RETURN

TH_CONTROL
	BCF MOD_STATUS,AD_DONE
	BTFSC TBF_CNT, 0
	GOTO TH_CONT_0
	BTFSC TBF_CNT, 1
	GOTO TH_CONT_1
	BTFSC TBF_CNT, 2
	GOTO TH_CONT_2
	BTFSC TBF_CNT, 3
	GOTO TN_CONT_3
	BTFSC TBF_CNT, 4
	GOTO TH_CONT_4
	BTFSC TBF_CNT, 5
	GOTO TH_CONT_5
	BTFSC TBF_CNT, 6
	GOTO TH_CONT_6
	GOTO TN_CONT_7
TH_CONT_0
	MOVF RET_VOL,W
	MOVWF TBF_BF
	CLRF THBF_HALF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	MOVWF THBF_1
	BCF TBF_CNT,0
	BSF TBF_CNT,1
	RETURN
TH_CONT_1
	MOVF RET_VOL,W
	MOVWF TBF_BF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	ADDWF THBF_1
	BTFSC THBF_HALF,1
	INCF THBF_1,F
	BCF TBF_CNT,1
	BSF TBF_CNT,2
	RETURN
TH_CONT_2
	MOVF RET_VOL,W
	MOVWF TBF_BF
	CLRF THBF_HALF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	MOVWF THBF_2
	BCF TBF_CNT,2
	BSF TBF_CNT,3
	RETURN
TH_CONT_3
	MOVF RET_VOL,W
	MOVWF TBF_BF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	ADDWF THBF_2
	BTFSC THBF_HALF,1
	INCF THBF_1,F
	BCF TBF_CNT,3
	BSF TBF_CNT,4
	RETURN
TH_CONT_4
	MOVF RET_VOL,W
	MOVWF TBF_BF
	CLRF THBF_HALF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	MOVWF THBF_3
	BCF TBF_CNT,4
	BSF TBF_CNT,5
	RETURN
TH_CONT_5
	MOVF RET_VOL,W
	MOVWF TBF_BF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	ADDWF THBF_3
	BTFSC THBF_HALF,1
	INCF THBF_1,F
	BCF TBF_CNT,5
	BSF TBF_CNT,6
	RETURN
TH_CONT_6
	MOVF RET_VOL,W
	MOVWF TBF_BF
	CLRF THBF_HALF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	MOVWF THBF_4
	BCF TBF_CNT,6
	BSF TBF_CNT,7
	RETURN
TH_CONT_7
	MOVF RET_VOL,W
	MOVWF TBF_BF
	BTFSC TBF_BF,0
	INCF THBF_HALF,F
	RRF TBF_BF,F
	MOVF TBF_BF,W
	ADDWF THBF_4
	BTFSC THBF_HALF,1
	INCF THBF_1,F
	CLRF THBF_HALF
	BTFSC THBF_1,0
	INCF THBF_HALF,F
	BTFSC THBF_2,0
	INCF THBF_HALF,F	
	RRF THBF_1
	RRF THBF_2
	MOVF THBF_1,W
	ADDWF THBF_2
	BTFSC THBF_HALF,1
	INCF THBF_2,F	
	CLRF THBF_HALF
	BTFSC THBF_3,0
	INCF THBF_HALF,F
	BTFSC THBF_4,0
	INCF THBF_HALF,F
	RRF THBF_3
	RRF THBF_4
	MOVF THBF_3,W
	ADDWF THBF_4
	BTFSC THBF_HALF,1
	INCF THBF_4,F		
	CLRF THBF_HALF
	BTFSC THBF_2,0
	INCF THBF_HALF,F
	BTFSC THBF_4,0
	INCF THBF_HALF,F
	RRF THBF_2
	RRF THBF_4
	MOVF THBF_2,W
	ADDWF THBF_4
	BTFSC THBF_HALF,1
	INCF THBF_4,F
	MOVF THBF_4,W
	MOVWF TBF_BF
	RRF TBF_BF,W
	ADDWF THBF_4
	MOVF THBF_4,W
	MOVWF CR_TH
	BCF TBF_CNT,7
	BSF TBF_CNT,0
	RETURN
TH_CALC
	CLRF T_1
	CLRF T_10
	CLRF T_100
TH_CALC_LOOP
	MOVF CR_TH_BUFF,W
	BTFSC STATUS,ZF
	RETURN
	DECF CR_TH_BUFF,F
	INCF T_1,F
	MOVLW .10
	SUBWF T_1,W
	BTFSS STATUS,ZF
	GOTO TH_CALC_LOOP
	CLRF T_1
	INCF T_10
	MOVLW .10
	SUBWF T_10,W
	BTFSS STATUS,ZF
	GOTO TH_CALC_LOOP
	CLRF T_10
	INCF T_100
	GOTO TH_CALC_LOOP

DOT_1_ON_BLINK
	BTFSC SP_STATUS, DOT_CHECK1
	GOTO DOT_1_OFF
	GOTO DOT_1_ON 
DOT_1_OFF
	BCF GP_STATUS, DOT_SWT1
	RETURN
DOT_1_ON
	BSF GP_STATUS, DOT_SWT1
	RETURN	
	
DOT_2_ON_BLINK
	BTFSC SP_STATUS, DOT_CHECK1
	GOTO DOT_2_OFF
	GOTO DOT_2_ON 
DOT_2_OFF
	BCF GP_STATUS, DOT_SWT2
	RETURN
DOT_2_ON
	BSF GP_STATUS, DOT_SWT2
	RETURN	
	
DOT_3_ON_BLINK
	BTFSC SP_STATUS, DOT_CHECK1
	GOTO DOT_3_OFF
	GOTO DOT_3_ON 
DOT_3_OFF
	BCF GP_STATUS, DOT_SWT3
	RETURN
DOT_3_ON
	BSF GP_STATUS, DOT_SWT3
	RETURN
	
DOT_4_ON_BLINK
	BTFSC SP_STATUS, DOT_CHECK1
	GOTO DOT_4_OFF
	GOTO DOT_4_ON 
DOT_4_OFF	
	BCF GP_STATUS, DOT_SWT4
	RETURN
DOT_4_ON
	BSF GP_STATUS, DOT_SWT4
	RETURN

;######################
;Stack structure
;######################
;RST_FSR
; reset FSR
;######################
RST_FSR
	MOVLW 40H
	MOVWF FSR
	RETURN

;######################
;PUSH_STACK / POP_STACK
;######################
PUSH_STACK
	MOVWF INDF
	INCF FSR,F
	RETURN

POP_STACK
	DECF FSR,F
	MOVF INDF,W
	CLRF INDF
	RETURN
	
;######################
;LAP_REG
; SEC - MIN - HR - TEMP, push 4 time.
;######################
LAP_REG
	SWAPF D_10SEC,W
	MOVWF STACK_BF
	MOVF D_1SEC,W
	ADDWF STACK_BF
	MOVF STACK_BF,W
	CALL PUSH_STACK
	SWAPF D_10MIN,W
	MOVWF STACK_BF
	MOVF D_1MIN,W
	ADDWF STACK_BF
	MOVF STACK_BF,W
	CALL PUSH_STACK
	SWAPF D_10HR,W
	MOVWF STACK_BF
	MOVF D_1HR,W
	ADDWF STACK_BF
	MOVF STACK_BF,W
	CALL PUSH_STACK
	MOVF CR_TH,W
	CALL PUSH_STACK
	RETURN

;######################
;LAP_POP
; TEMP - HR - MIN - SEC, pop 4 time.
;######################
LAP_POP
	CALL POP_STACK
	MOVWF CR_TH_LAP
	CALL POP_STACK
	MOVWF STACK_BF
	ANDLW 0FH
	MOVWF D_1HR_B
	SWAPF STACK_BF,W
	ANDLW 0FH
	MOVWF D_10HR_B
	CALL POP_STACK
	MOVWF STACK_BF
	ANDLW 0FH
	MOVWF D_1MIN_B
	SWAPF STACK_BF,W
	ANDLW 0FH
	MOVWF D_10MIN_B
	CALL POP_STACK
	MOVWF STACK_BF
	ANDLW 0FH
	MOVWF D_1SEC_B
	SWAPF STACK_BF,W
	ANDLW 0FH
	MOVWF D_10SEC_B
	RETURN

CLOCKMODY_RESET_SEC
	CLRF SEC_1
	CLRF SEC_10
	RETURN

CLOCKMODY_INCF_MIN
	INCF D_1MIN
	MOVLW .10
	SUBWF D_1MIN,W
	BTFSS STATUS,ZF
	RETURN
	CLRF D_1MIN
	INCF D_10MIN
	MOVLW .6
	SUBWF D_10MIN,W
	BTFSS STATUS,ZF
	RETURN
	CLRF D_10MIN
	RETURN
	RETURN
	
CLOCKMODY_INCF_HOUR
	INCF D_1HR
	INCF D_THR
	MOVLW .10
	SUBWF D_1HR,W
	BTFSS STATUS,ZF
	GOTO C_INCF_HR_2
	CLRF D_1HR
	INCF D_10HR
C_INCF_HR_2
	MOVLW .24
	SUBWF D_THR,W
	BTFSS STATUS,ZF
	RETURN
	CLRF D_THR
	CLRF D_10HR
	CLRF D_1HR
	RETURN
	
CLOCKMODY_DECF_MIN
	MOVF D_1MIN,W
	BTFSC STATUS,ZF
	GOTO D_1MIN_ZF
	DECF D_1MIN
	RETURN
D_1MIN_ZF
	MOVF D_10MIN,W
	BTFSC STATUS,ZF
	GOTO D_10MIN_ZF
	DECF D_10MIN
	MOVLW .9
	MOVWF D_1MIN
	RETURN
D_10MIN_ZF
	MOVLW .9
	MOVWF D_1MIN
	MOVLW .5
	MOVWF D_10MIN
	RETURN

CLOCKMODY_DECF_HOUR
	MOVF D_1HR,W
	BTFSC STATUS,ZF
	GOTO D_1HR_ZF
	DECF D_1HR
	DECF D_THR
	RETURN
D_1HR_ZF
	MOVF D_10HR,W
	BTFSC STATUS,ZF
	GOTO D_10HR_ZF
	DECF D_10HR
	MOVLW .9
	MOVWF D_1HR
	DECF D_THR
	RETURN
D_10HR_ZF
	MOVLW .3
	MOVWF D_1HR
	MOVLW .2
	MOVWF D_10HR
	MOVLW .23
	MOVWF D_THR
	RETURN
	RETURN
	
MODE_CONV
	BTFSC MOD_STATUS, MODE2
	GOTO CLOCK_TO_THER
	BCF MOD_STATUS, MODE2
	BSF MOD_STATUS, MODE1
	RETURN
CLOCK_TO_THER
	BSF MOD_STATUS, MODE2
	BCF MOD_STATUS, MODE1
	RETURN

CHECK_NEXTLAP
	MOVF LAP_NUM,W
	BTFSC STATUS,ZF
	GOTO LAP_ENDED
	BCF SWT_STATUS, LAP_OV
	DECF LAP_NUM
	CALL LAP_POP
	MOVF LAP_NUM,W
	BTFSC STATUS,ZF
	GOTO LAP_LAST
	RETURN
LAP_LAST
	BCF SWT_STATUS,LAP_EXT
	RETURN
LAP_ENDED
	BCF MOD_STATUS,MODE4
	RETURN

;######################
;Display subroutine
;######################
DISPBF_CONTROL
	BCF GP_STATUS,DOT_SWT1
	BCF GP_STATUS,DOT_SWT2
	BCF GP_STATUS,DOT_SWT3
	BCF GP_STATUS,DOT_SWT4
	BCF SWT_STATUS,LED_SWT1
	BCF SWT_STATUS,LED_SWT2
	BCF SWT_STATUS,LED_SWT3
	BTFSC MOD_STATUS, MODE4
	GOTO DISP_LAPCHECK
	BTFSC MOD_STATUS, MODE3
	GOTO DISP_CLOCKMODY
	BTFSC MOD_STATUS, MODE2
	GOTO DISP_COMMON_CLOCK
	GOTO DISP_COMMON_THER
DISP_COMMON_CLOCK
	CALL DOT_4_ON_BLINK
	BSF SWT_STATUS,LED_SWT2
	BTFSS SWT_STATUS,HM_CONV
	GOTO DISP_COMMON_CLOCK_HM
	GOTO DISP_COMMON_CLOCK_MS
DISP_COMMON_CLOCK_HM
	MOVF D_1MIN,W
	MOVWF DISPBF_4
	MOVF D_10MIN,W
	MOVWF DISPBF_3
	MOVF D_1HR,W
	MOVWF DISPBF_2
	MOVF D_10HR,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
DISP_COMMON_CLOCK_MS
	MOVF D_1SEC,W
	MOVWF DISPBF_4
	MOVF D_10SEC,W
	MOVWF DISPBF_3
	MOVF D_1MIN,W
	MOVWF DISPBF_2
	MOVF D_10MIN,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
DISP_COMMON_THER
	CALL DOT_4_ON_BLINK
	BSF SWT_STATUS,LED_SWT1
	MOVF CR_TH,W
	MOVWF CR_TH_BUFF
	CALL TH_CALC
	MOVF T_1,W
	MOVWF DISPBF_4
	MOVF TH_10,W
	MOVWF DISPBF_3
	MOVF TH_100,W
	MOVWF DISPBF_2
	MOVF STACK_NUM,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
DISP_CLOCKMODY
	BSF SWT_STATUS,LED_SWT2
	BTFSC CLK_STATUS,SEC
	GOTO DISPBF_CLOCKMODY_SEC
	MOVF D_1SEC,W
	MOVWF DISPBF_4
	MOVF D_10SEC,W
	MOVWF DISPBF_3
	MOVF D_1MIN,W
	MOVWF DISPBF_2
	MOVF D_10MIN,W
	MOVWF DISPBF_1
	BTFSC CLK_STATUS,HOUR
	GOTO DISP_CLOCKMODY_HOUR
	CALL DOT_3_ON_BLINK
	CALL DOT_4_ON_BLINK
	GOTO XLOOP_END
DISP_CLOCKMODY_HOUR
	CALL DOT_1_ON_BLINK
	CALL DOT_2_ON_BLINK
	GOTO XLOOP_END
DISP_CLOCKMODY_SEC
	MOVF D_1SEC,W
	MOVWF DISPBF_4
	MOVF D_10SEC,W
	MOVWF DISPBF_3
	MOVF D_1MIN,W
	MOVWF DISPBF_2
	MOVF D_10MIN,W
	MOVWF DISPBF_1
	CALL DOT_3_ON_BLINK
	CALL DOT_4_ON_BLINK
	GOTO XLOOP_END
DISP_LAPCHECK
	BSF SWT_STATUS,LED_SWT3
	BTFSC MOD_STATUS, MODE2
	GOTO DISP_CHECK_CLOCK
	GOTO DISP_CHECK_THER
DISP_CHECK_CLOCK
	BSF SWT_STATUS,LED_SWT2
	BTFSS SWT_STATUS,HM_CONV
	GOTO DISP_CHECK_CLOCK_HM
	GOTO DISP_CHECK_CLOCK_MS
DISP_CHECK_CLOCK_HM
	MOVF D_1MIN_B,W
	MOVWF DISPBF_4
	MOVF D_10MIN_B,W
	MOVWF DISPBF_3
	MOVF D_1HR_B,W
	MOVWF DISPBF_2
	MOVF D_10HR_B,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
DISP_CHECK_CLOCK_MS
	MOVF D_1SEC_B,W
	MOVWF DISPBF_4
	MOVF D_10SEC_B,W
	MOVWF DISPBF_3
	MOVF D_1MIN_B,W
	MOVWF DISPBF_2
	MOVF D_10MIN_B,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
DISP_CHECK_THER
	BSF SWT_STATUS,LED_SWT1
	MOVF CR_TH_LAP,W
	MOVWF CR_TH_BUFF
	CALL TH_CALC
	MOVF T_1,W
	MOVWF DISPBF_4
	MOVF TH_10,W
	MOVWF DISPBF_3
	MOVF TH_100,W
	MOVWF DISPBF_2
	MOVF STACK_NUM,W
	MOVWF DISPBF_1
	GOTO XLOOP_END
	
;######################
;Button subroutine
;######################

BT_1
	BTFSC MOD_STATUS, MODE4
	GOTO BT_1_LAPCHECK
	BTFSC MOD_STATUS, MODE3
	GOTO BT_1_CLOCKMODY
	BTFSC MOD_STATUS, MODE2
	GOTO BT_1_COMMON_CLOCK
	GOTO BT_1_COMMON_THER
BT_2
	BTFSC MOD_STATUS, MODE3
	GOTO BT_2_CLOCKMODY
	GOTO MODE_CONV
BT_3
	BTFSC MOD_STATUS, MODE4
	GOTO BT_3_LAPCHECK
	BTFSC MOD_STATUS, MODE3
	GOTO BT_3_CLOCKMODY
	BTFSC MOD_STATUS, MODE2
	GOTO BT_3_COMMON_CLOCK
	GOTO BT_3_COMMON_THER

BT_1_COMMON_THER
	BTFSC SWT_STATUS, LAP_OV
	GOTO LAP_PLUS_OVER
	BSF SWT_STATUS,LAP_EXT
	INCF LAP_NUM
	CALL LAP_REG
	BTFSC LAP_NUM,2
	BSF SWT_STATUS, LAP_OV
	RETURN
LAP_PLUS_OVER
	CALL BEEP_2
	RETURN
	
BT_1_COMMON_CLOCK
	BTFSS SWT_STATUS, HM_CONV
	GOTO HM_CONV_SET
	BCF SWT_STATUS,HM_CONV
	RETURN
HM_CONV_SET
	BSF SWT_STATUS,HM_CONV
	RETURN
	
BT_1_CLOCKMODY
	BTFSC CLK_STATUS, SEC
	GOTO CLOCKMODY_RESET_SEC
	BTFSC CLK_STATUS, MIN
	GOTO CLOCKMODY_INCF_MIN
	BTFSC CLK_STATUS, HOUR
	GOTO CLOCKMODY_INCF_HOUR
	
BT_1_LAPCHECK
	; do nothing
	RETURN
	
BT_2_CLOCKMODY
	BTFSC CLK_STATUS, SEC
	GOTO CLOCKMODY_RESET_SEC
	BTFSC CLK_STATUS, MIN
	GOTO CLOCKMODY_DECF_MIN
	BTFSC CLK_STATUS, HOUR
	GOTO CLOCKMODY_DECF_HOUR

BT_3_COMMON_THER
	BSF MOD_STATUS,MODE4
	GOTO CHECK_NEXTLAP
BT_3_COMMON_CLOCK
	BSF MOD_STATUS,MODE3
	BSF CLK_STATUS,HOUR
	BCF SWT_STATUS,HM_CONV
	RETURN
BT_3_CLOCKMODY
	BTFSC CLK_STATUS,SEC
	GOTO BT_3_CLOCKMODY_END
	RLF CLK_STATUS
	RETURN
BT_3_CLOCKMODY_END
	CLRF CLK_STATUS
	BCF MOD_STATUS,MODE3
	RETURN
BT_3_LAPCHECK
	GOTO CHECK_NEXTLAP

END