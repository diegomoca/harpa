// initialization
s.latency = nil;
// set up osc client
~oscClient = NetAddr("localhost", 57121);

// initialize midi
MIDIClient.init;
MIDIIn.connectAll;

// load file to initiate control busses
"control-busses.scd".loadRelative;

// audio bus to send string to 2 stereo bodies
~bodyBus = Bus.audio(s, 4);

// create a group for strings and one for bodies
// so that the bodies are always under the strings on the server
~stringsGroup = Group.new;
~bodiesGroup = Group.after(~stringsGroup);

// array to index voices (number of elements = number of "strings")
~keyArr = nil!11;

// array to index ressonators (number of elements = number of "bodies")
~bodyArr = nil!2;
