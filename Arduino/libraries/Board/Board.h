#include <inttypes.h>

// Declare buttons

// Call buttons
#define C1 5
#define C2 6
#define C3 7
#define C4 8
#define C5 9

// Channel select
#define CH0 A3
#define CH1 A4

// Station select
#define ST0 0
#define ST1 1
// Not used on current board due to lack of space for call buttons
#define ST2 4

#define MIC A0
#define SPKR 3
#define POWER_PIN A5

// Not connected, but we output signals on these pins for debugging
// bringing these out on a future board rev to tiny LEDs would be clever...
#define RX_LED A1
#define TX_LED A2

#define BUTTON_DEBOUNCE_TICKS 320
#define SAMPLE_RATE 8000

#define EVENT_BUTTON_UP 1
#define EVENT_BUTTON_DOWN 2

// Event handlers should return true if the want the event flag to be cleared
typedef bool (*ButtonEventHandler)(void);

class Board {

	volatile bool bounce;

	volatile int buttonState;

	uint16_t bounceTicks;

	int sampleRate;

	int _nodeId();

	ButtonEventHandler buttonDownEventHandler;
	ButtonEventHandler buttonUpEventHandler;

public:

	Board();

	volatile uint16_t ticks;

	int buttonEvents;
	int buttons;

	uint8_t boardId;

	void initialise();

	void setButtonDownHandler(ButtonEventHandler handler);
	void setButtonUpHandler(ButtonEventHandler handler);

	void handleButtonEvents();

	// Debounce the buttons and return any events generated
	uint8_t getButtonEvents();
	int readButtons();

	// Set the buttons up as inputs with pullups enabled
	// Enable pin-change interrupts
	void initialiseButtons();

	void handleButtonInterrupt();

	void showSource(int source);

	void setAnalogEnabled(bool enabled);
	void setADCEnabled(bool enabled);
	void setDACEnabled(bool enabled);

	// Start the timers which are used to drive the DAC and ADC
	// Also used to count ticks for timeouts and button debounce
	void startTimers();

};
