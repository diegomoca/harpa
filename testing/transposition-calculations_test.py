from fractions import Fraction
genInterval = Fraction(3/2)
cyInterval = Fraction(2/1)
fundamental = 1
notesNumber = 5

# DEG   TRANS
# up    up
frequency = fundamental
for x in range(notesNumber):
    print(frequency)
    frequency = frequency * genInterval
    if frequency > cyInterval:
        frequency = frequency / cyInterval
# down  up
print("")
frequency = fundamental
for x in range(notesNumber):
    print(frequency)
    frequency = frequency / genInterval
    if frequency < fundamental:
        frequency = frequency * cyInterval
# down  down
print("")
frequency = fundamental
for x in range(notesNumber):
    print(frequency)
    frequency = frequency / genInterval
    if frequency < fundamental / cyInterval:
        frequency = frequency * cyInterval
# up    down
print("")
frequency = fundamental
for x in range(notesNumber):
    print(frequency)
    frequency = frequency * genInterval
    if frequency > fundamental:
        frequency = frequency / cyInterval

