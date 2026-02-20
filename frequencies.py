# import OSC functions
from osc4py3.as_eventloop import *
from osc4py3 import oscbuildparse

# start OSC client to send messages
osc_startup()
osc_udp_client('127.0.0.1', 57120, 'scOSCClient')
print("OSCClient started. Ready to send messages")

fundamental = 100
mode = 2
transposition = 0
maxInterval = 2
interval = 7 / 4
noteNumber = 5
frequencies = []

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

for x in range(10):
    osc_process()

osc_terminate()
