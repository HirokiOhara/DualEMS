/*
 List all the available serial ports
 ,and open the port you are using at the rate you want */

Serial portOpen() {
  printArray(Serial.list());
  return new Serial(this, Serial.list()[5], 460800);
}
