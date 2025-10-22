// PLC Interface for Intelligent Sorting System
// Modbus RTU communication example
#include <ModbusRTU.h>
ModbusRTU mb;
void setup() {
  mb.begin(&Serial);
  mb.slave(1);
}
void loop() {
  mb.task();
  // Read and write registers accordingly
}
