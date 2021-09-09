// PushLua - Yet another Ableton Push Lua Framework
// (c) 2021 - Mockba the Borg
// This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
// I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
//

#include <iostream>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include "RtMidi/RtMidi.h"

RtMidiIn  *midiIn  = 0;
RtMidiOut *midiOut = 0;

#define SLEEP( milliseconds ) usleep( (unsigned long) (milliseconds * 1000.0) )

int nextNote = 0;	// Used to force the next note

int counter[10] = {0,0,0,0,0,0,0,0,0,0};
int reset[10] = {0,0,0,0,0,0,0,0,0,0};

void mycallback( double deltatime, std::vector< unsigned char > *message, void * /*userData*/ )
{
	std::vector<unsigned char> messageOut;
	
	int ctr = 0;

	int byte0 = (int)message->at(0);
	int byte1 = (int)message->at(1);
	int byte2 = (int)message->at(2);

	std::cout << "Message : ";
	switch(byte0) {
		case 0x90:	// Received Note On
			if(nextNote)	// Override if nextNote is set
				byte1 = nextNote;
			std::cout << "Note On " << byte1;
			switch(byte1) {
				case 56:
				case 57:
				case 58:
				case 59:
				case 60:
				case 61:
				case 62:
				case 63:
				case 95:
				case 112:
				case 113:
					messageOut.push_back(byte0);
					messageOut.push_back(byte1);
					messageOut.push_back(byte2);
					midiOut->sendMessage(&messageOut);
					std::cout << " sent out\n";
					break;
				default:
					std::cout << " ignored\n";
			}
			break;
		case 0x80:	// Received Note Off
			if(nextNote) {	// Override if nextNote is set
				byte1 = nextNote;
				nextNote = 0;
			}
			std::cout << "Note Off " << byte1;
			switch(byte1) {
				case 56:
				case 57:
				case 58:
				case 59:
				case 60:
				case 61:
				case 62:
				case 63:
				case 95:
				case 112:
				case 113:
					messageOut.push_back(byte0);
					messageOut.push_back(byte1);
					messageOut.push_back(byte2);
					midiOut->sendMessage(&messageOut);
					std::cout << " sent out\n";
					break;
				default:
					std::cout << " ignored\n";
			}
			break;
		case 0xB0:	// Received Continuous Controller
			if(byte1 > 9 && byte1 < 20) {		// CC 10-19 = Set counter 0-9 to CC value
				ctr = byte1-10;
				reset[ctr] = byte2;				// Set the reset (wraparound) value
				counter[ctr] = byte2;			// Set the counter value
				std::cout << "Counter " << ctr << " set to " << byte2 << "\n";
				break;
			}
			if(byte1 > 19 && byte1 < 30) {		// CC 20-29 = Decrement counter 0-9
				ctr = byte1-20;
				counter[ctr]--;
				std::cout << "Counter " << ctr << " decremented to " << counter[ctr] << "\n";
				if(!counter[ctr]) {				// If counter got to zero
					nextNote = byte2;			// Override the next note to CC value
					counter[ctr] = reset[ctr];	// Reset the counter
					std::cout << "Counter " << ctr << " reset\n";
				}
				break;
			}
			std::cout << "CC " << byte1 << "=" << byte2 << " ignored\n";
			break;
		default:	// Received something else, ignore message
			std::cout << "Message " << byte0 << " ignored\n";
	}
}

int main( int argc, char ** /*argv[]*/ )
{
  try {

    // RtMidiIn constructor
    midiIn = new RtMidiIn();
    // Set our callback function.  This should be done immediately after
    // opening the port to avoid having incoming messages written to the
    // queue instead of sent to the callback function.
    midiIn->setCallback( &mycallback );
    // Ignore sysex, timing, and active sensing messages.
    midiIn->ignoreTypes( true, true, true );
	// Open input Virtual Port
	midiIn->openVirtualPort("Automation In");

  } catch ( RtMidiError &error ) {
    error.printMessage();
  }

  try {

    // RtMidiOut constructor
    midiOut = new RtMidiOut();
	// Open output Virtual Port
	midiOut->openVirtualPort("Automation Out");

  } catch ( RtMidiError &error ) {
    error.printMessage();
  }

  std::cout << "Midiloop v1.1 by Mockba the Borg\n";
//  std::cout << "Looping ... press <enter> to quit.\n";
//  char input;
//  std::cin.get(input);
  while(true) {
	  SLEEP(500);
  }

  delete midiIn;
  delete midiOut;

  return 0;
}
