# import OSC functions
import time
from osc4py3.as_eventloop import * # needed to send and receive OSC
from osc4py3 import oscbuildparse # needed to send OSC
from osc4py3 import oscmethod as osm # needed to receive OSC

# start OSC 
osc_startup()
# set up client to send messages
osc_udp_client('127.0.0.1', 57120, 'scOSCClient')
print("OSC Client started. Ready to send messages!")
# set up OSC server to receive messages
osc_udp_server("127.0.0.1", 57121, 'scOSCServer')
print("OSC Server started. Ready to receive messages!")

finished = False
try:
    while True:
        osc_process()
        time.sleep(0.001)
except KeyboardInterrupt:
    osc_terminate()
