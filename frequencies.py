fundamental = 100
mode = 0
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

    print(frequencies)
else:
    print("false mode number!")
