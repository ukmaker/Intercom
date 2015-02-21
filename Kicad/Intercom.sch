EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:ShedScope
LIBS:SparkFun
LIBS:Intercom-cache
EELAYER 24 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 4
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 4500 3450 2750 1400
U 54985100
F0 "Microphone" 50
F1 "Microphone.sch" 50
F2 "MIC" I L 4500 4100 60 
F3 "SPKR" I L 4500 4300 60 
$EndSheet
$Sheet
S 4500 1250 2900 1400
U 54985106
F0 "Power" 50
F1 "Power.sch" 50
F2 "3V3DIGITAL" I R 7400 2350 60 
F3 "3V3ANALOG" I R 7400 2050 60 
F4 "9VSWITCHED" I R 7400 1700 60 
F5 "POWERON" I L 4500 1700 60 
$EndSheet
$Sheet
S 1050 1050 2200 1600
U 54985109
F0 "Control" 50
F1 "Control.sch" 50
F2 "MIC" I R 3250 1900 60 
F3 "SPKR" I R 3250 2100 60 
F4 "POWERON" I R 3250 1700 60 
$EndSheet
$Comp
L +9V #PWR01
U 1 1 5498721B
P 8300 1550
F 0 "#PWR01" H 8300 1520 20  0001 C CNN
F 1 "+9V" H 8300 1660 30  0000 C CNN
F 2 "" H 8300 1550 60  0000 C CNN
F 3 "" H 8300 1550 60  0000 C CNN
	1    8300 1550
	1    0    0    -1  
$EndComp
$Comp
L VAA #PWR02
U 1 1 5498722F
P 8600 1550
F 0 "#PWR02" H 8600 1610 30  0001 C CNN
F 1 "VAA" H 8600 1660 30  0000 C CNN
F 2 "" H 8600 1550 60  0000 C CNN
F 3 "" H 8600 1550 60  0000 C CNN
	1    8600 1550
	1    0    0    -1  
$EndComp
$Comp
L +3.3V #PWR03
U 1 1 54987243
P 8900 1550
F 0 "#PWR03" H 8900 1510 30  0001 C CNN
F 1 "+3.3V" H 8900 1660 30  0000 C CNN
F 2 "" H 8900 1550 60  0000 C CNN
F 3 "" H 8900 1550 60  0000 C CNN
	1    8900 1550
	1    0    0    -1  
$EndComp
Wire Wire Line
	7400 1700 8300 1700
Wire Wire Line
	8300 1700 8300 1550
Wire Wire Line
	7400 2050 8600 2050
Wire Wire Line
	8600 2050 8600 1550
Wire Wire Line
	7400 2350 8900 2350
Wire Wire Line
	8900 2350 8900 1550
Wire Wire Line
	3250 1700 4500 1700
Wire Wire Line
	4200 1900 4200 4100
Wire Wire Line
	4200 4100 4500 4100
Wire Wire Line
	3250 2100 3850 2100
Wire Wire Line
	3850 2100 3850 4300
Wire Wire Line
	3850 4300 4500 4300
Wire Wire Line
	3250 1900 4200 1900
$EndSCHEMATC
