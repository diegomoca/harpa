# import OSC functions
import time
from osc4py3.as_eventloop import * # needed to send and receive OSC
from osc4py3 import oscbuildparse # needed to send OSC
from osc4py3 import oscmethod as osm # needed to receive OSC

fundamental = 100
mode = 0
transposition = 0
maxInterval = 2
interval = 7 / 4
notesNumber = 5
frequencies = []

# DEFINE FUNCTIONS
# function to calculate frecuencies
def calculateFreqs(): 
    global frequencies
    frequencies = []
    if 0 <= mode < notesNumber:
        frequency = fundamental
        frequencies.append(frequency)
        for x in range(notesNumber - mode - 1):
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

        for x in range(notesNumber):
            frequencies.append(frequencies[x] * maxInterval)

        frequencies.append(frequencies[0] * maxInterval ** 2)
        frequencies.sort()

    else:
        print("false mode number!")

# send frequencies through OSC
def sendFreqs():
    osc_send(oscbuildparse.OSCMessage(
        '/freqs', ',fffffffffff', frequencies
    ),'scOSCClient')

# define mode cycle function
def cycleModes(message):
    global mode, frequencies

    # previouus mode
    print(f"mode change: {message}")
    if message == "prev":
        if mode > 0:
            mode -= 1
            calculateFreqs()
    # next mode
    if message == "next":
        if mode < notesNumber - 1:
            mode += 1
            calculateFreqs()
    
    # send new frequencies
    sendFreqs()
    
    freqsRounded = [round(x, 2) for x in frequencies]
    print(
        f"current mode: {mode + 1}/{notesNumber}\n"
        f"frequencies: {freqsRounded}\n"
    )

# start OSC 
osc_startup()
# set up client to send messages
osc_udp_client('127.0.0.1', 57120, 'scOSCClient')
print("OSC Client started. Ready to send messages!")
# set up OSC server to receive messages
osc_udp_server("127.0.0.1", 57121, 'scOSCServer')
print("OSC Server started. Ready to receive messages!")

# calculate initial frequencies
calculateFreqs()
print(frequencies, "\n")

# osc method to call cycleModes function
osc_method("/mode", cycleModes)


finished = False
try:
    while True:
        osc_process()
        time.sleep(0.001)
except KeyboardInterrupt:
    osc_terminate()


