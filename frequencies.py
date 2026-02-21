# import OSC functions
import time
from osc4py3.as_eventloop import * # needed to send and receive OSC
from osc4py3 import oscbuildparse # needed to send OSC
from osc4py3 import oscmethod as osm # needed to receive OSC

fundamental = 100
mode = 2
transposition = 0
maxInterval = 2
interval = 7 / 4
noteNumber = 5
frequencies = []

# define OSC handler function
def oscTestFunction(value):
    print(value)


# start OSC 
osc_startup()
# set up client to send messages
osc_udp_client('127.0.0.1', 57120, 'scOSCClient')
print("OSC Client started. Ready to send messages!")
# set up OSC server to receive messages
osc_udp_server("127.0.0.1", 57121, 'scOSCServer')
print("OSC Server started. Ready to receive messages!")

osc_method("/test", oscTestFunction)

if 0 <= mode < noteNumber:
    frequency = fundamental
    frequencies.append(frequency)
    for x in range(noteNumber - mode - 1):
        frequency *= interval
        while frequency > fundamental * maxInterval:
            frequency /= 2
        frequencies.append(frequency)

    frequency = fundamental
    for x in range(mode):
        frequency /= interval
        while frequency < fundamental:
            frequency *= 2
        frequencies.append(frequency)

    for x in range(noteNumber):
        frequencies.append(frequencies[x] * maxInterval)

    frequencies.append(frequencies[0] * maxInterval ** 2)
    frequencies.sort()

else:
    print("false mode number!")

# send frequencies through OSC
osc_send(oscbuildparse.OSCMessage(
    '/freqs', ',fffffffffff', frequencies
),'scOSCClient')


finished = False
try:
    while True:
        osc_process()
        time.sleep(0.001)
except KeyboardInterrupt:
    osc_terminate()


