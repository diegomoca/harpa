// create control buses and give initial values
// ADSR1 parameters
~attack1Bus = Bus.control(s, 1);
~attack1Bus.value_(0.01);
~decay1Bus = Bus.control(s, 1);
~decay1Bus.value_(0.3);
~sustain1Bus = Bus.control(s, 1);
~sustain1Bus.value_(0.5);
~release1Bus = Bus.control(s, 1);
~release1Bus.value_(1);
~curve1Bus = Bus.control(s, 1);
~curve1Bus.value_(-4);
// trigger parameters
~trigFreqBus = Bus.control(s, 1);
~trigFreqBus.value_(0);
~trigDurBus = Bus.control(s, 1);
~trigDurBus.value_(0.01);
~trigMethBus = Bus.control(s, 1);
~trigMethBus.value_(0);
// string parameters
// ~striFreqBus = Bus.control(s, 1);
// ~striFreqBus.value_(300);
~striVolBus = Bus.control(s, 1);
~striVolBus.value_(0.2);
~accentBus = Bus.control(s, 1);
~accentBus.value_(0.5);
~striStructBus = Bus.control(s, 1);
~striStructBus.value_(0.1);
~striBrightBus = Bus.control(s, 1);
~striBrightBus.value_(0.2);
~striDampBus = Bus.control(s, 1);
~striDampBus.value_(0.8);
// body parameters
// ~bodVolBus = Bus.control(s, 1);
// ~bodVolBus.value_(0.2);
// ~bodFreqBus = Bus.control(s, 1);
// ~bodFreqBus.value_(0.2);
~bodStructBus = Bus.control(s, 1);
~bodStructBus.value_(0.2);
~bodBrightBus = Bus.control(s, 1);
~bodBrightBus.value_(0);
// ~bodDampBus = Bus.control(s, 1);
// ~bodDampBus.value_(0.2);
