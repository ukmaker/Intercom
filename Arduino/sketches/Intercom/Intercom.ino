#include <Board.h>
#include <RFM12BE.h>
#include <Interface.h>

#include <avr/sleep.h>
#include <avr/power.h>

// For RFM12B
#define NETWORKID 99

// Size of the audio buffer
#define BUFSIZE 64
// Baud rate of the radio
#define RFM_115KBAUD 3

#define INTERCOM_MODE_START_RX 1
#define INTERCOM_MODE_RX 2
#define INTERCOM_MODE_TX 3

// The delay between received packets should be less than this
#define RX_TIMEOUT_TICKS 64

// If no activity for one second, go back to sleep
#define IDLE_TIMEOUT_TICKS 8000

// Events for the whole intercom
#define INTERCOM_EVENT_TX_BUF_FULL   0x01
#define INTERCOM_EVENT_IDLE_TIMEOUT  0x02
#define INTERCOM_EVENT_RX_TIMEOUT    0x04

RFM12BE radio;
Board board;
Interface interface;


// Volatile variables are modified by the ISRs
volatile bool txBufReady;
volatile bool dacDataAvailable = false;
volatile uint8_t intercomEvents;
volatile bool wokenByRx = false;
volatile int bufPtr;

uint8_t* buf;


int intercomMode = INTERCOM_MODE_START_RX;

unsigned long debounceTicks = 0;
unsigned long lastPacketReceivedTicks = 0;
unsigned long startedIdlingTicks = 0;

int destination = -1;



void setup() {

    // switch off analog comparator to save a bit of power
    ACSR = B10000000;

    lastPacketReceivedTicks=0;
    startedIdlingTicks=0;

    board.initialise();
    board.startTimers();
    board.setButtonDownHandler(buttonDownEventHandler);
    board.setButtonUpHandler(buttonUpEventHandler);

    radio.setInterface(&interface);
    radio.initialise(board.boardId, RF12_433MHZ, NETWORKID, 0 , RFM_115KBAUD, 0);
    radio.registerEventHandler(EVENT_RX_PACKET, packetReceivedEventHandler);
    radio.registerEventHandler(EVENT_TX_READY, packetSentEventHandler);

    attachInterrupt(0, radioInterruptHandler, LOW);

    radio.startReceive();
    board.setDACEnabled(true);
}

void loop() {

    // button events override everything else
    board.handleButtonEvents();

    // handle radio events
    radio.dispatchEvents();

    updateTimeouts();       
    handleTimeoutEvents();
}


bool buttonDownEventHandler() {

    // Turn on the ADC
    board.setDACEnabled(false);
    intercomEvents = 0;
    board.setAnalogEnabled(true);

    // abort any current radio operations and get ready to send
    buf = radio.startTransmit();
    bufPtr=0;
    intercomMode = INTERCOM_MODE_TX;
    board.setADCEnabled(true);
    // Turn off any LEDs which were on because we my have been in receive mode
    // otherwise we'll stay stuck in tx forever
    board.initialiseButtons();
    destination = board.readButtons();
    return true;
}

bool buttonUpEventHandler() {

    // stop the ADC interrupt handler
    board.setADCEnabled(false);
    intercomEvents = 0;
    // stop the radio transmitter and start receiving
    radio.startReceive();
    intercomMode = INTERCOM_MODE_START_RX;
    // turn off the analog for now - no point in using power until we
    // have received a packet to playback
    board.setAnalogEnabled(false);
    board.setDACEnabled(true);
    return true;
}

bool packetReceivedEventHandler() {
    buf = radio.getBuffer();
    bufPtr = 0;

    if(intercomMode == INTERCOM_MODE_START_RX) {
        board.setAnalogEnabled(true);
        board.setDACEnabled(true);
        intercomMode = INTERCOM_MODE_RX;
    }
    lastPacketReceivedTicks = board.ticks;
    board.showSource(radio.getSenderId());
    dacDataAvailable = true;

    return true;
}

bool packetSentEventHandler() {

    if(intercomEvents & INTERCOM_EVENT_TX_BUF_FULL) {
        // ready to send the next packet
        radio.send(board.buttons, BUFSIZE);
        intercomEvents &= ~INTERCOM_EVENT_TX_BUF_FULL;
        // finished with this event
        return true;
    }

    // haven't finished with this radio event yet
    return false;
}

bool updateTimeouts() {

    if((intercomMode != INTERCOM_MODE_RX) && (intercomMode != INTERCOM_MODE_START_RX)) {
        return false;
    }

    uint16_t delay = board.ticks - lastPacketReceivedTicks;

    if((intercomMode == INTERCOM_MODE_START_RX) && (delay > IDLE_TIMEOUT_TICKS)) {
        intercomEvents |= INTERCOM_EVENT_IDLE_TIMEOUT;
    } 
    else if(delay > RX_TIMEOUT_TICKS) {
        intercomEvents |= INTERCOM_EVENT_RX_TIMEOUT;
    }
}

void rxTimeoutEventHandler() {
    board.setAnalogEnabled(false);
    board.initialiseButtons();
    intercomMode = INTERCOM_MODE_START_RX;
}

void handleTimeoutEvents() {
    if(intercomEvents & INTERCOM_EVENT_RX_TIMEOUT) {
        rxTimeoutEventHandler();
        intercomEvents &= ~INTERCOM_EVENT_RX_TIMEOUT;
    }

    if(intercomEvents & INTERCOM_EVENT_IDLE_TIMEOUT) {
        idleTimeoutEventHandler();
        intercomEvents &= ~INTERCOM_EVENT_IDLE_TIMEOUT;
    }
}

void idleTimeoutEventHandler() {
    byte adcsra = ADCSRA;
    byte admux = ADMUX;
    byte didr0 = DIDR0;
    byte didr1 = DIDR1;
    byte prr = PRR;

    // Turn off power to the analog section
    board.setAnalogEnabled(false);

    // put the radio into snooze mode
    // so that it wakes up every 350ms to check for a packet
    radio.sleepLDC(0x0260,1);

    noInterrupts();
    sleep_enable();
    set_sleep_mode(SLEEP_MODE_PWR_DOWN);

    // stop watch-dog timer
    /* Clear WDRF in MCUSR */
    MCUSR &= ~(1<<WDRF);
    /* Write logical one to WDCE and WDE */
    /* Keep old prescaler setting to prevent unintentional time-out */
    WDTCSR |= (1<<WDCE) | (1<<WDE);
    /* Turn off WDT */
    WDTCSR = 0x00;  

    // make sure no digital inputs are enabled on the analog pins
    DIDR0 = 0;
    DIDR1 = 0;

    // switch off the adc
    ADCSRA =0;
    ADMUX=0;

    PRR=0XFF;

    // attach a wakeup handler to the radio int pin
    attachInterrupt(0, wokenByRxInterruptHandler, LOW);
    wokenByRx = false;

    // turn off brown-out enable in software
    MCUCR = bit (BODS) | bit (BODSE);  // turn on brown-out enable select
    MCUCR = bit (BODS);        // this must be done within 4 clock cycles of above
    interrupts ();             // guarantees next instruction executed
    sleep_cpu ();              // sleep within 3 clock cycles of above
    //noInterrupts();  
    // Back from sleep here
    // Re-enable the hardware we were using
    sleep_disable();
    ADMUX = admux;
    ADCSRA = adcsra;
    PRR = prr;
    DIDR0 = didr0;
    DIDR1 = didr1;
    powerUp();
}

void wokenByRxInterruptHandler() {
    sleep_disable();
    detachInterrupt(0);
    wokenByRx = true;
}

void powerUp() {

    radio.wakeup();
    attachInterrupt(0, radioInterruptHandler, LOW);

    if(wokenByRx) {
        intercomMode = INTERCOM_MODE_START_RX;
        lastPacketReceivedTicks = board.ticks;
    } 
    else {
        intercomMode = INTERCOM_MODE_TX;
    }
}

void radioInterruptHandler() {
    RFM12BE::interruptHandler(&radio);
}

ISR(PCINT0_vect) {
    board.handleButtonInterrupt();
} 

ISR(PCINT2_vect) {
    board.handleButtonInterrupt();
} 

// The Timer1 ISR handles dac
ISR(TIMER1_COMPA_vect) {

    // count ticks during receive
    // note that this will break when it wraps. Oh well
    board.ticks++;

    if(!dacDataAvailable) {
        return;
    }

    OCR2B = buf[bufPtr++];
    if(bufPtr >= BUFSIZE) {
        dacDataAvailable = false;
    }
}

// This isn't used, but seems to be needed to trigger the ADC
ISR(TIMER1_COMPB_vect) {
    board.ticks++;
}

// The ADC ISR
ISR(ADC_vect) {

    buf[bufPtr++] = ADCH;

    if(bufPtr >= BUFSIZE) {
        buf = radio.getBuffer();
        bufPtr=0;
        intercomEvents |= INTERCOM_EVENT_TX_BUF_FULL;
    }
}


