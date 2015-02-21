#include "Arduino.h"
#include "Board.h"
#include <avr/sleep.h>
#include <avr/power.h>

Board::Board() {
	ticks = 0;
	bounceTicks = 0;
	bounce = false;
	sampleRate = 0;
	boardId = 0;
	buttons = -1;
	buttonEvents = 0;
}

void Board::initialise(){

	    pinMode(CH0, INPUT_PULLUP);
	    pinMode(CH1, INPUT_PULLUP);

	    pinMode(ST0, INPUT_PULLUP);
	    pinMode(ST1, INPUT_PULLUP);
	    pinMode(ST2, INPUT_PULLUP);

	    pinMode(SPKR, OUTPUT);
	    pinMode(POWER_PIN, OUTPUT);
	    digitalWrite(POWER_PIN, false);

	    pinMode(RX_LED, OUTPUT);
	    digitalWrite(RX_LED, 0);

	    pinMode(TX_LED, OUTPUT);
	    digitalWrite(TX_LED, 0);

	    boardId = _nodeId();

	    // disconnect the st input pullups to save power
	    pinMode(ST0, INPUT);
	    pinMode(ST1, INPUT);
	    pinMode(ST2, INPUT);

	    initialiseButtons();
}

void Board::setButtonDownHandler(ButtonEventHandler handler) {
	buttonDownEventHandler = handler;
}
void Board::setButtonUpHandler(ButtonEventHandler handler) {
	buttonUpEventHandler = handler;
}

void Board::handleButtonEvents() {

    if(getButtonEvents() & EVENT_BUTTON_DOWN) {
        if(buttonDownEventHandler()) {
        	buttonEvents &= ~EVENT_BUTTON_DOWN;
        }
    }

    if(getButtonEvents() & EVENT_BUTTON_UP) {
        if(buttonUpEventHandler()) {
        	buttonEvents &= ~EVENT_BUTTON_UP;
        }
    }
}



// return the id of this node by reading the Station select pins
// Node ids start at one: zero is the broadcast id
int Board::_nodeId() {
    int id = digitalRead(ST0) ? 1 : 0;
    id |= digitalRead(ST1) ? 2 : 0;
    id |= digitalRead(ST2) ? 4 : 0;
    return id+1;
}

// bounce is set by the button interrupt handler when a change is detected
uint8_t Board::getButtonEvents() {

	if(bounce) {
		if(buttonState != buttons) {
			bounceTicks = ticks;
			buttons = buttonState;
		} else if((ticks - bounceTicks) > BUTTON_DEBOUNCE_TICKS) {
			// This counts as a change
			bounce = false;

			if(buttonState == -1) {
				buttonEvents |= EVENT_BUTTON_UP;
			} else {
				buttonEvents |= EVENT_BUTTON_DOWN;
			}
		}
	}

	return buttonEvents;
}


// Returns the id of the node we're sending to by reading the C pins
// Mapping: C1=0 (broadcast), C2=1, C3=2 ....
int Board::readButtons() {

    if(digitalRead(C1) == 0) {
        return 0;
    }

    if(digitalRead(C2) == 0) {
        return 1;
    }

    if(digitalRead(C3) == 0) {
        return 2;
    }

    if(digitalRead(C4) == 0) {
        return 3;
    }

    if(digitalRead(C5) == 0) {
        return 4;
    }

    return -1;

}


void Board::initialiseButtons() {

    PCICR = 0x00;

    pinMode(C1, INPUT_PULLUP);
    pinMode(C2, INPUT_PULLUP);
    pinMode(C3, INPUT_PULLUP);
    pinMode(C4, INPUT_PULLUP);
    pinMode(C5, INPUT_PULLUP);

    // Detect button presses
    // c1,2,3 = pcint21,22,23
    PCMSK2 = 0x20;
    PCMSK2 = 0xe0;
    // c4,5   = pcint0,1
    PCMSK0 = 0x03;
    // enable interrupts on PCIE2 and PCIE0
    PCICR  = 0x05;
}

void Board::handleButtonInterrupt() {
    buttonState = readButtons();
    bounce = true;
}

// Light the relevant button's LED when a signal is received
// Make sure to disable the associated pin change interrupt first or weird things will happen
void Board::showSource(int source) {
    switch(source) {
    case 1:
        PCMSK2 = 0x90;
        pinMode(C2, OUTPUT);
        digitalWrite(C2, 0);
        break;
    case 2:
        PCMSK2 = 0x60;
        pinMode(C3, OUTPUT);
        digitalWrite(C3, 0);
        break;
    case 3:
        PCMSK0 = 0x02;
        pinMode(C4, OUTPUT);
        digitalWrite(C4, 0);
        break;
    case 4:
        PCMSK0 = 0x01;
        pinMode(C5, OUTPUT);
        digitalWrite(C5, 0);
        break;
    default:
        // do nothing
        break;
    }
}


void Board::setAnalogEnabled(bool enabled) {
	digitalWrite(POWER_PIN, enabled);
}

void Board::setADCEnabled(bool enabled) {
	cli();

	if(enabled) {
	    // set ADLAR in ADMUX (0x7C) to left-adjust the result
	    // ADCH will contain upper 8 bits
	    ADMUX |= 1 << ADLAR;
	    // Use the Vcc as the reference volatage
	    ADMUX |= B01000000;
	    // Set Mux3..0 to 0 to select A0 as the input
	    ADMUX &= B11110000;

	    // Set ADEN in ADCSRA (0x7A) to enable the ADC.
	    // Note, this instruction takes 12 ADC clocks to execute
	    ADCSRA |= B10000000;
	    // Set ADATE in ADCSRA (0x7A) to enable auto-triggering.
	    ADCSRA |= B00100000;

	    // Clear ADTS2..0 in ADCSRB (0x7B) to set trigger mode to TC1 Compare/MatchB
	    ADCSRB &= B11111000;
	    ADCSRB |= B00000101;

	    // Set the Prescaler to 64 (16MHz/64 = 250KHz)
	    // so one conversion takes 13/250K = 52us (19kHz)
	    ADCSRA |= B00000101;
	    // Set ADIE in ADCSRA (0x7A) to enable the ADC interrupt.
	    // Without this, the internal interrupt will not trigger.
	    ADCSRA |= B00001000;

	    // Kick off the first ADC
	    // Set ADSC in ADCSRA (0x7A) to start the ADC conversion
	    ADCSRA |=B01000000;

	    // enable the ADC interrupt
	    TIMSK1 |= _BV(OCIE1B);
	} else {
	    // disable the ADC
	    TIMSK1 &= ~_BV(OCIE1B);
	}

	sei();
}

void Board::setDACEnabled(bool enabled) {

	cli();

	if(enabled) {
	    // Disable timer0 (used for Arduino millis()) since it causes glitches in output
	    TIMSK0 = 0;

	    // Use internal clock (datasheet p.160)
	    ASSR &= ~(_BV(EXCLK) | _BV(AS2));

	    // Set fast PWM mode  (p.157)
	    TCCR2A |= _BV(WGM21) | _BV(WGM20);
	    TCCR2B &= ~_BV(WGM22);
	    // Do non-inverting PWM on pin OC2B (p.155)
	    // On the Arduino this is pin 3.
	    TCCR2A = (TCCR2A | _BV(COM2B1)) & ~_BV(COM2B0);
	    TCCR2A &= ~(_BV(COM2A1) | _BV(COM2A0));
	    // No prescaler (p.158)
	    TCCR2B = (TCCR2B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

	    // Set initial pulse width to 0 to mute the output.
	    OCR2B = 0;

	    // Enable the interrupt for the dac handler
	    TIMSK1 |= _BV(OCIE1A);

	} else {
	    // Disable the interrupt for the dac handler
	    TIMSK1 &= ~_BV(OCIE1A);
	}

	sei();

}

void Board::startTimers() {
    // CTC Mode WGM13:10 = 0100
    TCCR1A = 0;
    TCCR1B = (TCCR1B & ~_BV(WGM13)) | _BV(WGM12);

    // No clock prescaler
    TCCR1B = (TCCR1B & ~(_BV(CS12) | _BV(CS11))) | _BV(CS10);

    // Set the compare register (OCR1A).
    // OCR1A is a 16-bit register, so we have to do this with
    // interrupts disabled to be safe.
    OCR1A = F_CPU / SAMPLE_RATE;    // 16e6 / 8000 = 2000

    // This is used to trigger an ADC sample
    OCR1B = F_CPU / SAMPLE_RATE;
}
