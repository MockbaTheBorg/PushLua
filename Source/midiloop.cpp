// PushLua - Yet another Ableton Push Lua Framework
// (c) 2021 - Mockba the Borg
// This code is distributed under the "IDGAFAWYDWTCALAYGMPC" license, which means:
// I Don't Give A Fuck About What You Do With This Code As Long As You Give Me Proper Credit
//

#include <iostream>
#include <string>
#include <cstdio>
#include <cstdlib>
#include <unistd.h>
#include "RtMidi/RtMidi.h"

RtMidiIn  *midiIn  = 0;
RtMidiOut *midiOut = 0;

#define SLEEP( milliseconds ) usleep( (unsigned long) (milliseconds * 1000.0) )

const std::string FEATURE_SET_FOOTCONTROL = "FEATURE_SET_FOOTCONTROL";

int nextNote = 0;	// Used to force the next note

int counter[10] = {0,0,0,0,0,0,0,0,0,0};
int reset[10] = {0,0,0,0,0,0,0,0,0,0};

std::string featureSet;

int currentColumn = 0;

void mycallback( double deltatime, std::vector< unsigned char > *message, void * /*userData*/ )
{
	std::vector<unsigned char> messageOut;
	
	int ctr = 0;

	int byte0 = (int)message->at(0);
	int byte1 = (int)message->at(1);
	int byte2 = (int)message->at(2);
    
    auto sendMessage = [](std::vector<unsigned char> messageOut, int byte0, int byte1, int byte2) {
        messageOut.push_back(byte0);
        messageOut.push_back(byte1);
        messageOut.push_back(byte2);
        midiOut->sendMessage(&messageOut);
        std::cout << " sent out\n";
    };
    
    auto nextColumnNote = [] (bool assign) {
        currentColumn = (currentColumn + 1) % 8;
        return (assign ? 41 : 96) + currentColumn;
    };
    
    auto previousColumnNote = [] (bool assign) {
        currentColumn = (currentColumn + 7 ) % 8;
        return (assign ? 41 : 96) + currentColumn;
    };

    auto currentColumnNote = [] (bool assign) {
        return (assign ? 41 : 96) + currentColumn;
    };

    std::cout << "Message : ";
	switch(byte0) {
		case 0x90:	// Received Note On
			if(nextNote)	// Override if nextNote is set
				byte1 = nextNote;
			std::cout << "Note On " << byte1;
			switch(byte1) {
				case 56: // launch scene 1
				case 57: // launch scene 2
				case 58: // launch scene 3
				case 59: // launch scene 4
				case 60: // launch scene 5
				case 61: // launch scene 6
				case 62: // launch scene 7
				case 63: // launch scene 8
				case 95: // stop all
				case 112: // navigate up
				case 113: // navigate down
                    sendMessage(messageOut, byte0, byte1, byte2);
					break;
				default:
				    if (FEATURE_SET_FOOTCONTROL == featureSet) {
				        switch(byte1) {
                            case 41: // track assign button 1
                            case 42: // track assign button 2
                            case 43: // track assign button 3
                            case 44: // track assign button 4
                            case 45: // track assign button 5
                            case 46: // track assign button 6
                            case 47: // track assign button 7
                            case 48: // track assign button 8
                            case 49: // shift
                            case 67: // undo
                            case 91: // mute mode
                            case 92: // solo mode
                            case 93: // rec arm mode
                            case 94: // clip stop mode
                            case 96: // track select button 1
                            case 97: // track select button 2
                            case 98: // track select button 3
                            case 99: // track select button 4
                            case 100: // track select button 5
                            case 101: // track select button 6
                            case 102: // track select button 7
                            case 103: // track select button 8
                            case 118: // arp
                                sendMessage(messageOut, byte0, byte1, byte2);
                                break;
                            // some macro kind stuff: (123 - 126 seem unused so far :-)
                            case 123: // press previous track select button (relating to our column pointer)
                                sendMessage(messageOut, byte0, previousColumnNote(false), byte2);
                                break;
                            case 124: // press next track select button (relating to our column pointer)
                                sendMessage(messageOut, byte0, nextColumnNote(false), byte2);
                                break;
                            case 125: // directly rec arm previous track column (relating to our column pointer)
                                sendMessage(messageOut, 0x90, 93, 127);
                                sendMessage(messageOut, 0x80, 93, 0);
                                sendMessage(messageOut, byte0, previousColumnNote(true), byte2);
                                break;
                            case 126: // directly rec arm next track column (relating to our column pointer)
                                sendMessage(messageOut, 0x90, 93, 127);
                                sendMessage(messageOut, 0x80, 93, 0);
                                sendMessage(messageOut, byte0, nextColumnNote(true), byte2);
                                break;
                            default:
                                std::cout << " ignored\n";
				        }
				    } else {
				        std::cout << " ignored\n";
				    }
			}
			break;
		case 0x80:	// Received Note Off
			if(nextNote) {	// Override if nextNote is set
				byte1 = nextNote;
				nextNote = 0;
			}
			std::cout << "Note Off " << byte1;
			switch(byte1) {
				case 56: // launch scene 1
				case 57: // launch scene 2
				case 58: // launch scene 3
				case 59: // launch scene 4
				case 60: // launch scene 5
				case 61: // launch scene 6
				case 62: // launch scene 7
				case 63: // launch scene 8
				case 95: // stop all
				case 112: // navigate up
				case 113: // navigate down
					sendMessage(messageOut, byte0, byte1, byte2);
					break;
				default:
				    if (FEATURE_SET_FOOTCONTROL == featureSet) {
				        switch(byte1) {
                            case 41: // track assign button 1
                            case 42: // track assign button 2
                            case 43: // track assign button 3
                            case 44: // track assign button 4
                            case 45: // track assign button 5
                            case 46: // track assign button 6
                            case 47: // track assign button 7
                            case 48: // track assign button 8
                            case 49: // shift
                            case 67: // undo
                            case 91: // mute mode
                            case 92: // solo mode
                            case 93: // rec arm mode
                            case 94: // clip stop mode
                            case 96: // track select button 1
                            case 97: // track select button 2
                            case 98: // track select button 3
                            case 99: // track select button 4
                            case 100: // track select button 5
                            case 101: // track select button 6
                            case 102: // track select button 7
                            case 103: // track select button 8
                            case 114: // navigate left
                            case 115: // navigate right
				            case 118: // arp
                                sendMessage(messageOut, byte0, byte1, byte2);
                                break;
                            case 123: // release previous track select button (relating to our column pointer)
                            case 124: // release next track select button (relating to our column pointer)
                                // send button off to select column
                                sendMessage(messageOut, byte0, currentColumnNote(false), byte2);
                                break;
                            case 125: // directly rec arm previous track column (relating to our column pointer)
                            case 126: // directly rec arm next track column (relating to our column pointer)
                                // send button off to column function button
                                sendMessage(messageOut, byte0, currentColumnNote(true), byte2);
                                break;
                            default:
                                std::cout << " ignored\n";
				        }
				    } else {
				        std::cout << " ignored\n";
				    }
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

int main( int argc, char ** argv )
{
  if (argc > 1) featureSet = argv[1];

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
  while(true) {
	  SLEEP(500);
  }

  delete midiIn;
  delete midiOut;

  return 0;
}
